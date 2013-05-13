(provide 'eshell-user-func)

;; * func & alias
(defun eshell/ff(file)
  (find-file file))

(defun eshell/img(img)
  (propertize "Image" (quote display) (create-image (expand-file-name img))))

(defun eshell/ee ()
  (find-file (expand-file-name "_extensions/+eshell.el" *init-dir*)))

(defun eshell/aa ()
  (find-file eshell-aliases-file))

(defun eshell/rr ()
  (find-file (expand-file-name "_qref.org" work-dir)))

(defun eshell/ed (file1 file2)
  (ediff-files file1 file2))

(defun eshell/ro ()
  "Delete files matching pattern \".*~\" and \"*~\""
  (eshell/rm (directory-files "." nil "^\\.?.*~$" nil)))

;; ** alternate func
(defun eshell/less (&rest args)
  "Invoke `view-file' on a file. "less +42 foo" will go to line 42 in
    the buffer for foo."
  (while args
    (if (string-match "\\`\\+\\([0-9]+\\)\\'" (car args))
        (let* ((line (string-to-number (match-string 1 (pop args))))
               (file (pop args)))
          (tyler-eshell-view-file file)
          (goto-line line))
      (tyler-eshell-view-file (pop args)))))
(defalias 'eshell/more 'eshell/less)

;; * other func
(defun eshell-maybe-bol ()
  (interactive)
  (let ((p (point)))
    (eshell-bol)
    (if (= p (point))
        (beginning-of-line))))

(defun eshell/vi (&rest args)
  "Invoke `find-file' on the file.
\"vi +42 foo\" also goes to line 42 in the buffer."
  (while args
    (if (string-match "\\`\\+\\([0-9]+\\)\\'" (car args))
        (let* ((line (string-to-number (match-string 1 (pop args))))
               (file (pop args)))
          (find-file file)
          (goto-line line))
      (find-file (pop args)))))

(defun eshell/emacs (&rest args)
  "Open a file in emacs. Some habits die hard."
  (if (null args)
      ;; If I just ran "emacs", I probably expect to be launching
      ;; Emacs, which is rather silly since I'm already in Emacs.
      ;; So just pretend to do what I ask.
      (bury-buffer)
    ;; We have to expand the file names or else naming a directory in an
    ;; argument causes later arguments to be looked for in that directory,
    ;; not the starting directory
    (mapc #'find-file (mapcar #'expand-file-name (eshell-flatten-list (reverse args))))))

(defun eshell/xza (from &optional to)
  (let* ((tmp (concat to (make-temp-name "") ".tar"))
         (from (directory-file-name from))
         (to (concat (expand-file-name from to) ".txz")))
    (shell-command (format "tar cvf %s %s" tmp from))
    (shell-command (format "7z a -txz %s %s" to tmp))
    (delete-file tmp)))

(defun eshell/xzx (from &optional to)
  (let* ((tmp (concat to (make-temp-name "")))
         f)
    (shell-command (format "7z x -txz %s -o%s" from tmp))
    (setq f (car (directory-files tmp nil "tar")))
    (shell-command (format "cd %s && tar xf %s -C %s" tmp f to))
    (delete-directory tmp t)))


