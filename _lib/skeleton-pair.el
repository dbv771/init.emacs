(setq skeleton-pair t)
(defvar skeleton-pair-cond-alist
  '(
    (?\( . ((t _ ")")))
    (?\{ . (((char-bf '(?$ ?=)) _ "}")
            (t n _ n "}")))
    (?\[ . (((or (char-bf ?/)(char-bf ?=)) n _ n "]")
            (t _ "]")))
    (?/  . (((bolp) "*" n  _  n "*/")
            (t _)))
    (?.  . (((bolp) -1 "->")
            (t _)))
    (?\" . ((t _ "\"")))
    ))

(defadvice skeleton-pair-insert-maybe (around condition activate)
  (let* ((skeleton-pair-alist skeleton-pair-alist)
         (key last-command-event)
         (cnd (cdr (assq key skeleton-pair-cond-alist))))
    (while
        (and
         cnd
         (null
          (if (eval (caar cnd))
              (setq skeleton-pair-alist (list (cons key (cdar cnd))))
            nil)))
      (setq cnd (cdr cnd)))
    ;; (message (format "%S" skeleton-pair-alist))
    ad-do-it))

(defun char-bf (x)
  (let ((x (if (listp x) x (list x))))
    (save-excursion
      (skip-chars-backward " \t")
      (memq (char-before (point)) x))))

;;;###autoload
(defun skeleton-pair-alist-update ()
  (interactive)
  (mapc
   (lambda(x)
     ;; (local-set-key (char-to-string (cadr x)) 'skeleton-pair-insert-maybe)
     (define-key (current-local-map)
       (eval `(kbd ,(char-to-string (car x))))
       ;; (char-to-string (cadr x))
       'skeleton-pair-insert-maybe))
   skeleton-pair-cond-alist))
;; (skeleton-pair-alist-update)

