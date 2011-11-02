;;; eshell-tab.el --- Provide a tab-style interface to erc buffers.

;;; Commentary:

;; Provides tabs in the header-line to access different eshell buffers.

;; The ideas and implementation here are taken from erc-tab.el.

(require 'eshell)

;;; Code:

(defgroup eshell-tab nil
  "Provide a tab interface to eshell buffers.")

(defcustom eshell-tab-max-width 20
  "Maximum width of any one channel tab."
  :group 'eshell-tab
  :type 'number)

(defface eshell-tab-unselected-face
  '((((type x w32 mac) (class color))
     :background "Gray50" :foreground "Gray20"
     :underline "Gray85" :box (:line-width -1 :style released-button))
    (((class color))
     (:background "cyan" :foreground "black" :underline "blue")))
  "*Face to fontify unselected tabs."
  :group 'eshell-tab)

(defface eshell-tab-selected-face
  '((((type x w32 mac) (class color))
     :background "Gray85" :foreground "black"
     :underline "Gray85" :box (:line-width -1 :style released-button))
    (((class color))
     (:background "blue" :foreground "black" :underline "blue"))
    (t (:underline t)))
  "*Face to fontify selected tab."
  :group 'eshell-tab)

;;;
(defun eshell-new ()
  (interactive)
  (eshell t)
  (eshell-tab-update))

(setq *eshell-tab-stale-buffer* nil)

(defun eshell-buffer-p (b)
  (and (not (eq b *eshell-tab-stale-buffer*))
       (equalp 0 (string-match "*eshell*" (buffer-name b)))))

(defun eshell-buffers ()
  (require 'cl)
  (sort (remove-if-not #'eshell-buffer-p (buffer-list))
        (lambda (l r) (string< (buffer-name l) (buffer-name r)))))

(defun eshell-buffers-names ()
  (mapcar 'buffer-name (eshell-buffers)))

(defun next-eshell-buffer (b &optional back)
  (if (eshell-buffer-p b)
      (let ((bs (eshell-buffers)))
        (if (member b bs)
            (labels ((sch (ls)
                          (if (equalp b (car ls))
                              (if (cdr ls) (cadr ls) (car bs))
                            (sch (cdr ls)))))
              (if back (sch (nreverse bs)) (sch bs)))))))

(defun switch-to-eshell-buffer (buffer)
  (switch-to-buffer buffer)
  (eshell-tab-update))

(defun goto-next-eshell-buffer ()
  (interactive)
  (let ((b (next-eshell-buffer (current-buffer))))
    (if b (switch-to-eshell-buffer b))))

(defun goto-previous-eshell-buffer ()
  (interactive)
  (let ((b (next-eshell-buffer (current-buffer) t)))
    (if b (switch-to-eshell-buffer b))))

(defun eshell-iswitchb ()
  (interactive)
  (require 'iswitchb)
  (let ((iswitchb-make-buflist-hook
	 (lambda ()
	   (setq iswitchb-temp-buflist (eshell-buffers-names)))))
    (switch-to-eshell-buffer (iswitchb-read-buffer "Switch-to: " nil t))))

(defun eshell-tab-make-keymap (buffer)
  (let ((map (make-sparse-keymap))
	(fn `(lambda (e) (interactive "e")
	       (select-window (car (event-start e)))
	       (switch-to-buffer ,buffer))))
    (define-key map [header-line down-mouse-1] 'ignore)
    (define-key map [header-line drag-mouse-1] fn)
    (define-key map [header-line mouse-1] fn)
    map))

(defun eshell-tab-update ()
  "Update all tabs, as necessary."
  (mapcar 'eshell-tab-update-buffer (eshell-buffers-names)))

(defun eshell-tab-update-buffer (buffer)
  "Update the tabs in eshell buffer `buffer'."
  (let* ((bs (eshell-buffers-names))
         (no (length bs))
         (wd (min eshell-tab-max-width (/ (- (window-width) no) no))))
    (save-excursion
      (set-buffer buffer)
      (setq header-line-format
            (mapcar
             (lambda (b)
               (save-excursion
                 (set-buffer b)
                 (concat
                  (propertize
                   (concat " " (truncate-string-to-width
                                (eshell/pwd) (- wd 2) nil ?\ ) " ")
                   'face (if (eq b buffer)
                             'eshell-tab-selected-face
                           'eshell-tab-unselected-face)
                   'help-echo (eshell/pwd)
                   'local-map (eshell-tab-make-keymap b)) " ")))
             bs)))))

(defun eshell-tab-remove ()
  "Unset the header line for all eshell buffers."
  (save-excursion
    (mapcar
     (lambda (b) (set-buffer b) (setq header-line-format nil))
     (eshell-buffers))))

(add-hook 'eshell-mode-hook
          (lambda ()
            (define-key eshell-mode-map "\C-cs" 'eshell-new)
            (define-key eshell-mode-map "\C-cb" 'eshell-iswitchb)
            (define-key eshell-mode-map "\C-cn" 'goto-next-eshell-buffer)
            (define-key eshell-mode-map [(meta tab)] 'goto-next-eshell-buffer)
            (define-key eshell-mode-map "\C-cp" 'goto-previous-eshell-buffer)))

(add-hook 'eshell-directory-change-hook 'eshell-tab-update)

(defun eshell-tab-exit-hook ()
  (setq *eshell-tab-stale-buffer* (current-buffer))
  (eshell-tab-update))

(add-hook 'eshell-exit-hook 'eshell-tab-exit-hook)


(provide 'eshell-tab)
