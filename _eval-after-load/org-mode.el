;; -*- encoding: utf-8-unix; -*-
;; File-name:    <org-mode.el>
;; Create:       <2012-01-03 14:21:30 ran9er>
;; Time-stamp:   <2012-01-03 14:23:37 ran9er>
;; Mail:         <2999am@gmail.com>
;; *========== org-mode	
(load-once
 (setq org-hide-leading-stars t)
 (define-key global-map "\C-ca" 'org-agenda)
 (setq org-log-done 'time)
);load1
