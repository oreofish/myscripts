;; -*- mode: Emacs-Lisp -*-
;; Time-stamp: <2004-03-02 19:58:22 Yu Li>

;;{{{ cc-mode: use only spaces for indentation in cc-mode
(require 'cc-mode)
(defun my-build-tab-stop-list (width)
  (let ((num-tab-stops (/ 80 width))
        (counter 1)
        (ls nil))
    (while (<= counter num-tab-stops)
      (setq ls (cons (* width counter) ls))
      (setq counter (1+ counter)))
    (set (make-local-variable 'tab-stop-list) (nreverse ls))))
(defun my-c-mode-common-hook ()
  (setq tab-width 4) ;; change this to taste, this is what i uses :)
  (my-build-tab-stop-list tab-width)
  (setq c-basic-offset tab-width)
  (setq indent-tabs-mode nil)) ;; force only spaces for indentation
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)
;;}}}

;;{{{ css-mode : add css-mode support
(autoload 'css-mode "css-mode" "Mode for editing CSS files" t)
;;}}}

;;{{{ python-mode : add python-mode support

(autoload 'python-mode "python-mode" "Python editing mode." t)

;;}}}

;;{{{ php-mode : add php support
;;(require 'php-mode)
;;}}}

;;{{{ cedet: Collection of Emacs Development Enviromnent Tools
;; Configuration variables here:
;;(setq semantic-load-turn-useful-things-on t)
;; Load CEDET
;;(load-file "~/site-lisp/cedet/common/cedet.el")
;;(setq ede-project-placeholder-cache-file "~/.emacs.d/.projects.ede")
;;}}}

;;{{{ JDEE : Java Development Environment support

;;(require 'jde)
;;(setq jde-ant-home "C:\\apache-ant-1.5.3-1")

;;}}}

;;{{{ ECB : Emacs Code Browser support
;;(require 'ecb)
;;}}}

(setq auto-mode-alist
      (append '(("\\.py\\'" . python-mode)
                ("\\.css\\'" . css-mode))
              auto-mode-alist))

(setq interpreter-mode-alist
      (cons '("python" . python-mode)
            interpreter-mode-alist))
