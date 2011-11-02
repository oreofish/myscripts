;;; setnu-plus.el --- Extensions to `setnu.el'.
;;; FILE SHOULD BE NAMED setnu+.el, but Emacs Wiki doesn't like that.
;; 
;; Filename: setnu+.el
;; Description: Extensions to `setnu.el'.
;; Author: Drew Adams
;; Maintainer: Drew Adams
;; Copyright (C) 2000-2005, Drew Adams, all rights reserved.
;; Created: Thu Nov 30 08:51:07 2000
;; Version: 21.0
;; Last-Updated: Fri Dec 31 09:42:24 2004
;;           By: dradams
;;     Update #: 95
;; Keywords: 
;; Compatibility: GNU Emacs 21.x, GNU Emacs 20.x
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Commentary: 
;; 
;; Extensions to `setnu.el'.
;;
;;  Fixes setnu mode so that deletions of newlines are taken into
;;  account.
;;
;;  This code is based on `jde.el', by Paul Kinnucan
;;  <paulk@mathworks.com>, which, in turn, was apparently based on
;;  code by Jonathan Epstein <Jonathan_Epstein@nih.gov>.
;; 
;;  Library `setnu+' requires these libraries:
;;
;;    `setnu'.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Change log:
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;;; Code:

(and (< emacs-major-version 20) (eval-when-compile (require 'cl))) ;; when, unless
(require 'setnu)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(remove-hook 'before-change-functions 'setnu-before-change-function)
(remove-hook 'after-change-functions 'setnu-after-change-function)
(make-local-hook 'before-change-functions)
(make-local-hook 'after-change-functions)

(defvar setnu+-newline-deletion-check t
  "Non-nil means check for newline deletions when numbering lines
via `setnu'.")
(make-variable-buffer-local 'setnu+-newline-deletion-check)

(defun setnu+-after-change (start end length)
  "When in setnu-mode and newlines have been deleted, refreshes
by turning setnu-mode off, then back on."
  (if setnu-mode
      (when (or (and (> length 0) setnu+-newline-deletion-check)
                (string-match "[\n\r]" (buffer-substring-no-properties start end)))
        (run-with-timer 0.001 nil (lambda () (setnu-mode) (setnu-mode)))) ; Toggle 
    (setq setnu+-newline-deletion-check nil)))

(defun setnu+-before-change (start end) 
  "Determines whether any newlines are about to be deleted."
  (when (and setnu-mode (> end start))
    (setq setnu+-newline-deletion-check 
          (string-match "[\n\r]" (buffer-substring-no-properties start end)))))


;; REPLACES ORIGINAL in `setnu.el':
;; Adds/removes before/after change hooks.
;;;###autoload
(defun setnu-mode (&optional arg)
  "Toggle setnu-mode on/off.
Positive prefix argument turns setnu-mode on; negative turns it off.
When setnu-mode is on, a line number will appear at the left
margin of each line."
  (interactive "P")
  (let ((oldmode setnu-mode)
        (inhibit-quit t))
    (setq setnu-mode (if arg
                         (natnump (prefix-numeric-value arg))
                       (not setnu-mode)))
    (unless (eq oldmode setnu-mode)
      (cond (setnu-mode
             (add-hook 'before-change-functions 'setnu-before-change-function t t)
             (add-hook 'before-change-functions 'setnu+-before-change t t)
             (add-hook 'after-change-functions 'setnu-after-change-function t t)
             (add-hook 'after-change-functions 'setnu+-after-change t t)
             (setnu-mode-on))
            (t
             (remove-hook 'before-change-functions 'setnu-before-change-function t)
             (remove-hook 'before-change-functions 'setnu+-before-change t)
             (remove-hook 'after-change-functions 'setnu-after-change-function t)
             (remove-hook 'after-change-functions 'setnu+-after-change t)
             (setnu-mode-off))))))

;;;;;;;;;;;;;;;;;;;;;;;

(provide 'setnu+)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FILE SHOULD BE NAMED setnu+.el, but Emacs Wiki doesn't like that.
;;; setnu-plus.el ends here

