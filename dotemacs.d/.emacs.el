;; -*- mode: Emacs-Lisp -*-
;; Time-stamp: <2004-03-10 15:59:43 Yu Li>

(global-set-key [(meta g)] 'goto-line)
(global-set-key [(control a)] 'speedbar)
(global-set-key (kbd "M-<SPC>") 'set-mark-command)

;; setup for newline auto-appending support
(setq next-line-add-newline t)

;; make the title infomation more useful
(setq frame-title-format "emacs@%b")

;; setup up a big kill-ring, so i will never miss anything:-)
(setq kill-ring-max 50)

;; setup up for column number display in the mode line
(setq column-number-mode t)

;; set default mode to text-mode
(setq default-major-mode 'text-mode)

;; make dired can copy and delete directory
(setq dired-recursive-copies 'top)
(setq dired-recursive-deletes 'top)

;; disable the welcome screen
(setq inhibit-startup-message t)

;; name the buffers have same file name in the forward way
(setq uniquify-buffer-name-style 'forward)

;; time stamp support
(setq time-stamp-active t)
(setq time-stamp-warn-inactive t)
(add-hook 'write-file-hooks 'time-stamp)
(setq time-stamp-format "%:y-%02m-%02d %02H:%02M:%02S Yu Li")

;; backup settings
(setq version-control t)
(setq kept-old-versions 2)
(setq kept-new-versions 5)
(setq delete-old-versions t)
(setq backup-directory-alist '(("." . "~/backup")))
(setq backup-by-copying t)

;; setup various dot file's location
(setq bookmark-default-file "~/.emacs.d/_emacs_bmk")
(setq abbrev-file-name "~/.emacs.d/_abbrev_defs")
(setq custom-file "~/.emacs.d/_emacs_custom.el")
(setq bbdb-file "~/.emacs.d/_bbdb")
(setq todo-file-do "~/.emacs.d/todo-do")
(setq todo-file-done "~/.emacs.d/todo-done")
(setq todo-file-top "~/.emacs.d/todo-top")
(setq diary-file "~/.emacs.d/_diary")

;; setup default user information
(setq user-full-name "Yu Li")
(setq user-mail-address "liyu2000@hotmail.com")

;; setup chinese language support
(set-language-environment 'Chinese-GB)
(create-fontset-from-fontset-spec
  "-*-Courier New-normal-r-*-*-10-*-*-*-c-*-fontset-most,
  chinese-gb2312:-*-MS Song-normal-r-*-*-12-*-*-*-c-*-gb2312-*,
  chinese-big5-1:-*-MingLiU-normal-r-*-*-12-*-*-*-c-*-big5-*,
  chinese-big5-2:-*-MingLiU-normal-r-*-*-12-*-*-*-c-*-big5-*" t)
(set-keyboard-coding-system 'chinese-iso-8bit)
(set-clipboard-coding-system 'chinese-iso-8bit)

;; setup default font and init windows position
(set-default-font "-*-Courier New-normal-r-*-*-14-*-*-*-c-*-fontset-most")
(set-frame-height (selected-frame) 41)
(set-frame-width (selected-frame) 80)
(set-frame-position (selected-frame) 220 0)

;; load other settings
(load-file "~/.emacs.d/_emacs_tools.el")
(load-file "~/.emacs.d/_emacs_cygwin.el")
(load-file "~/.emacs.d/_emacs_wiki.el")
(load-file "~/.emacs.d/_emacs_modes.el")
(load-file "~/.emacs.d/_emacs_calendar.el")
(load-file custom-file)

;; turn on syntax highlighting
(global-font-lock-mode t)

;; setup parentheses handling
(show-paren-mode 1)
(transient-mark-mode t)

;; turn on image file support
(auto-image-file-mode)

;; Just cos I'm lazy, set up selection & keys like Windows.
(delete-selection-mode)

;; display time and mail notify icon on mode line
(display-time-mode 1)
(setq display-time-24hr-format t)
(setq display-time-day-and-date t)
(setq display-time-use-mail-icon t)
(setq display-time-interval 10)

;; session support
(require 'session)
(add-hook 'after-init-hook 'session-initialize)
(setq session-save-file "~/.emacs.d/_session")

;; desktop support
(load "desktop")
(setq desktop-base-file-name "_emacs_desktop")
(setq desktop-path '("." "~/.emacs.d"))
(setq desktop-enable t)
(desktop-load-default)
(desktop-read)
