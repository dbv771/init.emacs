(unless (boundp '*init-dir*)

  (let* (init-time
         (init-name-match "init.*emacs\\|emacs.*init")
         (base-dir
          (apply 'expand-file-name
                 (cond
                  (load-file-name
                   `(".." ,(file-name-directory load-file-name)))
                  ((eq system-type 'windows-nt)
                   `(".." ,exec-directory))
                  (t
                   `("~")))))
         (init-dir
          (file-name-as-directory
           (or
            (car
             (sort
              (mapcar (lambda (x) (if (file-directory-p x) x (make-temp-name "")))
                      (directory-files base-dir t init-name-match t))
              'file-newer-than-file-p))
            (make-temp-name ""))))
         (init-files
          (mapcar
           (lambda (f) (file-name-sans-extension f))
           (directory-files init-dir t "\\.el\\'"))))

    (when (file-exists-p init-dir)

      (setq init-time (list (float-time)))

      ;; export *init-dir*
      (defvar *init-dir* init-dir)

      ;; add "_xxx_" to load-path
      (mapc (lambda (p)
              (if (file-directory-p p)
                  (add-to-list 'load-path p)))
            (directory-files init-dir t "^_.*_\\'"))

      ;; autoload
      (funcall
       (lambda (dir &optional loaddefs basedir)
         (let* ((path
                 (expand-file-name dir (or basedir *init-dir*)))
                (ldfs
                 (or loaddefs "_loaddefs"))
                (generated-autoload-file
                 (expand-file-name ldfs path)))
           (update-directory-autoloads path)
           (kill-buffer ldfs)
           (load generated-autoload-file)))
       "_autoload_/")

      ;; *auto-hook-hash*
      (defvar *auto-hook-hash* (make-hash-table :test 'equal :size 20))
      (mapc
       (lambda (x)
         (puthash
          (file-name-sans-extension (file-name-nondirectory x)) x
          *auto-hook-hash*))
       (directory-files (expand-file-name "_extensions/" init-dir) t "\\.el\\'"))

      (add-hook 'find-file-hook
                '(lambda ()
                   (let* ((bf (buffer-name))
                          (mode
                           (catch 'md
                             (mapcar
                              (lambda (x)
                                (and
                                 (string-match (car x) bf)
                                 (throw 'md (symbol-name (cdr x)))))
                              auto-mode-alist))))
                     ;; (setq mode
                     ;;       (or mode
                     ;;           (and (string-equal "*" (substring bf 0 1))
                     ;;                (substring bf 1 -1))))
                     (load
                      (gethash mode *auto-hook-hash*
                               (make-temp-name ""))
                      t))))

      ;; byte-compile
      (when nil
        ;; delete elc without el
        (mapc (lambda(f)(or (file-exists-p (substring f 0 -1))
                        (delete-file f)))
              (directory-files init-dir t "\\.elc\\'"))
        ;; recompile
        (eval-when-compile (require 'bytecomp))
        (mapc (lambda(f) (byte-recompile-file f nil 0))
              (directory-files init-dir t "\\.el\\'")))

      ;; load *.elc || *.el in init-dir
      (defvar *init-time* nil)
      (let (tm)
        (mapc
         (lambda (f)
           (setq tm (float-time))
           (load f)
           (setq *init-time*
                 (cons
                  (cons
                   (file-name-nondirectory f)
                   (- (float-time) tm))
                  *init-time*)))
         init-files))

      (setcdr init-time (float-time))

      (let ((total (- (cdr init-time) (car init-time))))
        (setq *init-time*
              (append
               (list
                (cons 'Total
                      total)
                (cons 'other
                      (- total
                         (apply '+ (mapcar 'cdr *init-time*))))
                '---------------------------------------------)
               *init-time*)))

      ;; when init finished, echo some info
      (add-hook
       'emacs-startup-hook
       `(lambda ()
          (message "load %d init file , spend %g seconds ; startup spend %g seconds"
                   (- (length *init-time*) 3)
                   (cdar *init-time*)
                   (- (float-time) ,(car init-time))))))))
