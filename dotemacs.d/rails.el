;;; rails.el --- minor mode for editing RubyOnRails code

;; Copyright (C) 2006 Galinsky Dmitry <dima dot exe at gmail dot com>

;; Keywords: ruby rails languages oop
;; X-URL:    https://opensvn.csie.org/mvision/emacs/.emacs.d/rails.el
;; $Id$

;;; License

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

;;; Features

;; * Managment WEBrick/Mongrel
;; * Display color log file
;; * Switch beetwin Action/View
;; * TextMate like snippets (snippets.el)
;; * Automatic generate TAGS in RAILS_ROOT directory
;; * Quick access to configuration files
;; * Search in documentation using ri or chm file
;; * Quick start svn-status in RAILS_ROOT

;;; Install

;; Download
;;  * http://www.kazmier.com/computer/snippet.el
;;  * http://www.webweavertech.com/ovidiu/emacs/find-recursive.txt
;; and place into directory where emacs can find it.
;;
;; Add to your .emacs file:
;;
;; (defun try-complete-abbrev (old)
;;   (if (expand-abbrev) t nil))
;;
;; (setq hippie-expand-try-functions-list
;;       '(try-complete-abbrev
;;         try-complete-file-name
;;         try-expand-dabbrev))
;;
;; (require 'rails)
;;
;; If you want to use Mongrel instead of WEBrick, add this to you .emacs file:
;; (setq rails-use-mongrel t)
;;

;;; For Windows users only:

;;  If you want to use CHM file for help (by default used ri), add this to your .emacs file:
;;    (setq rails-chm-file "<full_path_to_rails_chm_manual>")
;;  Download and install KeyHH.exe from http://www.keyworks.net/keyhh.htm
;;
;;  Howto using Textmate Backtracer
;;   1. Place info you .emacs file:
;;
;;   (require 'gnuserv)
;;   (setq gnuserv-frame (selected-frame))
;;   (gnuserv-start)

;;   2. Create into you emacs bin directory txmt.js and place into it:
;;
;;   var wsh = WScript.CreateObject("WScript.Shell");
;;   url = WScript.Arguments(0);
;;   if (url) {
;;     var req = /file:\/\/([^&]+).*&line=([0-9]+)/;
;;     var file = req.exec(url);
;;     if (file[1] && file[2]) {
;;       wsh.Run("<path_to_emacs_bin_directory>/gnuclientw.exe +" + file[2] + " " + file[1]);
;;     }
;;   }

;;   3. Create registry key structure:
;;   HKEY_CLASSES_ROOT
;;   -- *txmt*
;;   ---- (Default) = "URL:TXMT Protocol"
;;   ---- URL Protocol = ""
;;   ---- *shell*
;;   ------ *open*
;;   -------- *command*
;;   ---------- (Default) = "cscript /H:WScript /nologo <path_to_emacs_bin_direcory>\txmt.js %1"

;;; BUGS:

;; Do not use automatic snippent expand, be various problem in mmm-mode.
;; Snippets now bind in <TAB>

;; More howtos, see
;;   * http://scott.elitists.net/users/scott/posts/rails-on-emacs
;;   * http://www.emacswiki.org/cgi-bin/wiki/RubyMode

;;; Changelog:

;; HEAD
;;   * add snippets for migration (Jason Stewart)
;;   * add macro def-snip and replace all snippets (Rezikov Peter)
;;   * Automatic check of availability posn-at-point
;;   * rails-switch-view-action: create [action].rhtml if view not exists
;;   * Remove function rails-ri-at-point and rename rails-ri-start to rails-search-doc
;;   * Check rails-chm-file exists before start keyhh
;;   * Fix not match def, if cursor position at begin of line in rails-switch-to-action
;;   * Remove etags support

;; 2006/02/09 (version 0.3)
;;   * Minor fixes in snippets, add extra "-" (Sanford Barr)
;;   * Fix problem at using TAB key
;;   * Display help using CHM manual
;;   * Fix undefined variable html-mode-abbrev-table in older emacs versions
;;   * Add variable rails-use-another-define-key
;;   * Fix void function indent-or-complete
;;   * Add Mongrel support
;;   * Fix compitation warnings
;;   * Display popup menu at point

;; 2006/02/07 (version 0.2)
;;   * Display color logs using ansi-color
;;   * Revert to using snippet.el
;;   * Automatic create TAGS file in RAILS_ROOT
;;   * add variable rails-use-ctags
;;   * fix problem in rails-create-tags (thanks Sanford Barr)
;;   * lazy load TAGS file

;; 2006/02/06 (version 0.1):
;;   * Cleanup code
;;   * Add menu item "SVN status"
;;   * Add menu item "Search documentation"
;;   * If one action associated to multiple views,
;;     display popup menu to a choice view
;;   * More TextMate snippets
;;   * Using ri to search documentation
;;   * Apply patch from Maiha Ishimura

;;; Code:

(eval-when-compile
  (require 'speedbar)
  (require 'ruby-mode))

(require 'ansi-color)
(require 'snippet)
(require 'etags)
(require 'find-recursive)

(defvar rails-version "0.3")
(defvar rails-ruby-command "ruby")
(defvar rails-webrick-buffer-name "*WEBrick*")
(defvar rails-webrick-port "3000")
(defvar rails-webrick-default-env "development")
(defvar rails-webrick-url (concat "http://localhost:" rails-webrick-port))
(defvar rails-templates-list '("rhtml" "rxml" "rjs"))
(defvar rails-chm-file nil "Path to CHM file or nil")
(defvar rails-use-another-define-key nil )
(defvar rails-use-mongrel nil "Non nil using Mongrel, else WEBrick")

(defvar rails-minor-mode-menu-bar-map
  (let ((map (make-sparse-keymap)))
    (define-key map [rails] (cons "RubyOnRails" (make-sparse-keymap "RubyOnRails")))
    (define-key map [rails svn-status]
      '(menu-item "SVN status"
                  (lambda()
                    (interactive)
                    (svn-status (rails-root))
                    :enable (rails-root))))
    (define-key map [rails tag] '("Update TAGS file" . rails-create-tags))
    (define-key map [rails ri] '("Search documentation" . rails-search-doc))
    (define-key map [rails separator] '("--"))
    (define-key map [rails snip] (cons "Snippets" (make-sparse-keymap "Snippets")))
    (define-key map [rails snip render] (cons "render" (make-sparse-keymap "render")))
    (define-key map [rails snip render sk-ra]  '("render (action)\t(ra)" . rails-snip-ra))
    (define-key map [rails snip render sk-ral] '("render (action,layout)\t(ral)" . rails-snip-ral))
    (define-key map [rails snip render sk-rf]  '("render (file)\t(rf)" . rails-snip-rf))
    (define-key map [rails snip render sk-rfu] '("render (file,use_full_path)\t(rfu)" . rails-snip-rfu))
    (define-key map [rails snip render sk-ri]  '("render (inline)\t(ri)" . rails-snip-ri))
    (define-key map [rails snip render sk-ril] '("render (inline,locals)\t(ril)" . rails-snip-ril))
    (define-key map [rails snip render sk-rit] '("render (inline,type)\t(rit)" . rails-snip-rit))
    (define-key map [rails snip render sk-rl]  '("render (layout)\t(rl)" . rails-snip-rl))
    (define-key map [rails snip render sk-rn]  '("render (nothing)\t(rn)" . rails-snip-rn))
    (define-key map [rails snip render sk-rns] '("render (nothing,status)\t(rns)" . rails-snip-rns))
    (define-key map [rails snip render sk-rp]  '("render (partial)\t(rp)" . rails-snip-rp))
    (define-key map [rails snip render sk-rpc] '("render (partial,collection)\t(rpc)" . rails-snip-rpc))
    (define-key map [rails snip render sk-rpl] '("render (partial,locals)\t(rpl)" . rails-snip-rpl))
    (define-key map [rails snip render sk-rpo] '("render (partial,object)\t(rpo)" . rails-snip-rpo))
    (define-key map [rails snip render sk-rps] '("render (partial,status)\t(rps)" . rails-snip-rps))
    (define-key map [rails snip render sk-rt] '("render (text)\t(rt)" . rails-snip-rt))
    (define-key map [rails snip render sk-rtl] '("render (text,layout)\t(rtl)" . rails-snip-rtl))
    (define-key map [rails snip render sk-rtlt] '("render (text,layout => true)\t(rtlt)" . rails-snip-rtlt))
    (define-key map [rails snip render sk-rcea] '("render_component (action)\t(rcea)" . rails-snip-rcea))
    (define-key map [rails snip render sk-rcec] '("render_component (controller)\t(rcec)" . rails-snip-rcec))
    (define-key map [rails snip render sk-rceca] '("render_component (controller, action)\t(rceca)" . rails-snip-rceca))

    (define-key map [rails snip redirect_to] (cons "redirect_to" (make-sparse-keymap "redirect_to")))
    (define-key map [rails snip redirect_to sk-rea] '("redirect_to (action)\t(rea)" . rails-snip-rea))
    (define-key map [rails snip redirect_to sk-reai] '("redirect_to (action, id)\t(reai)" . rails-snip-reai))
    (define-key map [rails snip redirect_to sk-rec] '("redirect_to (controller)\t(rec)" . rails-snip-rec))
    (define-key map [rails snip redirect_to sk-reca] '("redirect_to (controller, action)\t(reca)" . rails-snip-reca))
    (define-key map [rails snip redirect_to sk-recai] '("redirect_to (controller, action, id)\t(recai)" . rails-snip-recai))

    (define-key map [rails snip environment] (cons "environmnet" (make-sparse-keymap "controller")))
    (define-key map [rails snip environment sk-flash] '("flash[...]\t(flash)" . rails-snip-flash))
    (define-key map [rails snip environment sk-logi] '("logger.info\t(logi)" . rails-snip-logi))
    (define-key map [rails snip environment sk-params] '("params[...]\t(par)" . rails-snip-par))
    (define-key map [rails snip environment sk-session] '("session[...]\t(ses)" . rails-snip-ses))

    (define-key map [rails snip model] (cons "model" (make-sparse-keymap "model")))
    (define-key map [rails snip model bt] '("belongs_to (class_name,foreign_key)\t(bt)" . rails-snip-ar-bt))
    (define-key map [rails snip model hm] '("has_many (class_name,foreign_key,dependent)\t(hm)" . rails-snip-ar-hm))
    (define-key map [rails snip model ho] '("has_one (class_name,foreign_key,dependent)\t(ho)" . rails-snip-ar-ho))
    (define-key map [rails snip model vp] '("validates_presence_of\t(vp)" . rails-snip-ar-vp))
    (define-key map [rails snip model vu] '("validates_uniqueness_of\t(vu)" . rails-snip-ar-vu))
    (define-key map [rails snip model vn] '("validates_numericality_of\t(vn)" . rails-snip-ar-vn))

    (define-key map [rails snip migrations] (cons "migrations" (make-sparse-keymap "model")))
    (define-key map [rails snip migrations mct] '("create_table (table)\t(mct)" . rails-snip-mct))
    (define-key map [rails snip migrations mctf] '("create_table (table, force)\t(mctf)" . rails-snip-mctf))
    (define-key map [rails snip migrations mdt] '("drop_table (table)\t(mdt)" . rails-snip-mdt))
    (define-key map [rails snip migrations mtcl] '("t.column (column)\t(mtcl)" . rails-snip-mtcl))
    (define-key map [rails snip migrations mac] '("add_column (table, column, type)\t(mac)" . rails-snip-mac))
    (define-key map [rails snip migrations mcc] '("change_column (table, column, type)\t(mcc)" . rails-snip-mcc))
    (define-key map [rails snip migrations mrec] '("rename_column (table, name, new_name)\t(mrec)" . rails-snip-mrec))
    (define-key map [rails snip migrations mrmc] '("remove_column (table, column)\t(mrmc)" . rails-snip-mrmc))
    (define-key map [rails snip migrations mai] '("add_index (table, column)\t(mai)" . rails-snip-mai))
    (define-key map [rails snip migrations mait] '("add_index (table, column, type)\t(mait)" . rails-snip-mait))
    (define-key map [rails snip migrations mrmi] '("remove_index (table, column)\t(mrmi)" . rails-snip-mrmi))

    (define-key map [rails snip rhtml] (cons "rhtml" (make-sparse-keymap "rhtml")))
    (define-key map [rails snip rhtml sk-erb-ft] '("form_tag\t(ft)" . rails-snip-erb-ft))
    (define-key map [rails snip rhtml sk-erb-lia] '("link_to (action)\t(lia)" . rails-snip-erb-lia))
    (define-key map [rails snip rhtml sk-erb-liai] '("link_to (action, id)\t(liai)" . rails-snip-erb-liai))
    (define-key map [rails snip rhtml sk-erb-lic] '("link_to (controller)\t(lic)" . rails-snip-erb-lic))
    (define-key map [rails snip rhtml sk-erb-lica] '("link_to (controller, action)\t(lica)" . rails-snip-erb-lica))
    (define-key map [rails snip rhtml sk-erb-licai] '("link_to (controller, action, id)\t(licai)" . rails-snip-erb-licai))
    (define-key map [rails snip rhtml sk-erb-ft] '("form_tag\t(ft)" . rails-snip-erb-ft))
    (define-key map [rails snip rhtml sk-erb-h] '("<% h ... %>\t(%h)" . rails-snip-erb-h))
    (define-key map [rails snip rhtml sk-erb-if] '("<% if/end %>\t(%if)" . rails-snip-erb-if))
    (define-key map [rails snip rhtml sk-erb-unless] '("<% unless/end %>\t(%unless)" . rails-snip-erb-unless))
    (define-key map [rails snip rhtml sk-erb-ifel] '("<% if/else/end %>\t(%ifel)" . rails-snip-erb-ifel))
    (define-key map [rails snip rhtml sk-erb-block] '("<% ... %>\t(%)" . rails-snip-erb-block))
    (define-key map [rails snip rhtml sk-erb-echo-block] '("<%= ... %>\t(%%)" . rails-snip-erb-echo-block))

    (define-key map [rails log] (cons "Open log" (make-sparse-keymap "Open log")))
    (define-key map [rails log test]
      '("test.log" . (lambda() (interactive) (rails-open-log "test"))))
    (define-key map [rails log pro]
      '("production.log" . (lambda() (interactive) (rails-open-log "production"))))
    (define-key map [rails log dev]
      '("development.log" . (lambda() (interactive) (rails-open-log "development"))))

    (define-key map [rails config] (cons "Configuration" (make-sparse-keymap "Configuration")))
    (define-key map [rails config routes]
      '("routes.rb" .
        (lambda()
          (interactive)
          (let ((root (rails-root)))
            (if root (find-file (concat root "config/routes.rb")))))))
    (define-key map [rails config environment]
      '("environment.rb" .
        (lambda()
          (interactive)
          (let ((root (rails-root)))
            (if root (find-file (concat root "config/environment.rb")))))))
    (define-key map [rails config database]
      '("database.yml" .
        (lambda()
          (interactive)
          (let ((root (rails-root)))
            (if root (find-file (concat root "config/database.yml")))))))
    (define-key map [rails config boot]
      '("boot.rb" .
        (lambda()
          (interactive)
          (let ((root (rails-root)))
            (if root (find-file (concat root "config/boot.rb")))))))

    (define-key map [rails config env] (cons "environments" (make-sparse-keymap "environments")))
    (define-key map [rails config env test]
      '("test.rb" .
        (lambda()
          (interactive)
          (let ((root (rails-root)))
            (if root (find-file (concat root "config/environments/test.rb")))))))
    (define-key map [rails config env production]
      '("production.rb" .
        (lambda()
          (interactive)
          (let ((root (rails-root)))
            (if root (find-file (concat root "config/environments/production.rb")))))))
    (define-key map [rails config env development]
      '("development.rb" .
        (lambda()
          (interactive)
          (let ((root (rails-root)))
            (if root (find-file (concat root "config/environments/development.rb")))))))

    (define-key map [rails webrick] (cons "WEBrick" (make-sparse-keymap "WEBrick")))

    (define-key map [rails webrick mongrel]
      '(menu-item "Use Mongrel" rails-toggle-use-mongrel
                  :enable (not (rails-webrick-process-status))
                  :button (:toggle
                           . (and (boundp 'rails-use-mongrel)
                                   rails-use-mongrel))))

    (define-key map [rails webrick separator] '("--"))

    (define-key map [rails webrick buffer]
      '(menu-item "Show buffer"
                  rails-webrick-open-buffer
                  :enable (rails-webrick-process-status)))
    (define-key map [rails webrick url]
      '(menu-item "Open browser"
                  rails-webrick-open-browser
                  :enable (rails-webrick-process-status)))
    (define-key map [rails webrick stop]
      '(menu-item "Stop"
                  rails-webrick-process-stop
                  :enable (rails-webrick-process-status)))
    (define-key map [rails webrick test]
      '(menu-item "Start test"
                  (lambda() (interactive)
                    (rails-webrick-process "test"))
                  :enable (not (rails-webrick-process-status))))
    (define-key map [rails webrick production]
      '(menu-item "Start production"
                  (lambda() (interactive)
                    (rails-webrick-process "production"))
                  :enable (not (rails-webrick-process-status))))
    (define-key map [rails webrick development]
      '(menu-item "Start development"
                  (lambda() (interactive)
                    (rails-webrick-process "development"))
                  :enable (not (rails-webrick-process-status))))

    (define-key map [rails switch-va] '("Switch Action/View" . rails-switch-view-action))

    map))

(defmacro* def-snip (name &key snip abbrev abbrev-table )
  "  This macro create function with name ``name'', witch generate a snip.
   Also macro sets symbol property ``no-self-insert'' to avoid bug, where
<space>
   replace first default snip value.
   If abbrev and abbrev-table is not nil, macro generate abbrev for this
snip."
  `(progn
     (defun ,name () (interactive)
       (snippet-insert ,snip))
     (put ',name 'no-self-insert t)
     ,@(if (and abbrev abbrev-table)
           (let ((abbrev-tables (if (not (listp abbrev-table))
                                    (list abbrev-table)
                                  abbrev-table)))
             (mapcar #'(lambda (table)
                         `(define-abbrev ,table ,abbrev  "" ',name))
                     abbrev-tables)))))

(defun rails-abbrev-init ()
  "Initialize ruby abbrev table"

  ;; Controller
  (def-snip rails-snip-ra
    :snip "render :action => \"$${action}\""
    :abbrev "ra"
    :abbrev-table ruby-mode-abbrev-table)


  (def-snip rails-snip-ral
    :snip "render :action => \"$${action}\", :layout => \"$${layoutname}\""
    :abbrev "ral"
    :abbrev-table ruby-mode-abbrev-table)


  (def-snip rails-snip-rf
    :snip "render :file => \"$${filepath}\""
    :abbrev "rf"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-rfu
    :snip "render :file => \"$${filepath}\", :use_full_path => $${false}"
    :abbrev "rfu"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-ri
    :snip "render :inline => \"$${<%= 'hello' %>}\""
    :abbrev "ri"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-ril
    :snip "render :inline => \"$${<%= 'hello' %>}\", :locals => { $${name} => \"$${value}\" }"
    :abbrev "ril"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-rit
    :snip "render :inline => \"$${<%= 'hello' %>}\", :type => :$${rxml})"
    :abbrev "rit"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-rl
    :snip "render :layout => \"$${layoutname}\""
    :abbrev "rl"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-rn
    :snip "render :nothing => $${true}"
    :abbrev "rn"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-rns
    :snip "render :nothing => $${true}, :status => $${401}"
    :abbrev "rns"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-rp
    :snip "render :partial => \"$${item}\""
    :abbrev "rp"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-rpc
    :snip "render :partial => \"$${item}\", :collection => $${items}"
    :abbrev "rpc"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-rpl
    :snip "render :partial => \"$${item}\", :locals => { :$${name} => \"$${value}\"}"
    :abbrev "rpl"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-rpo
    :snip "render :partial => \"$${item}\", :object => $${object}"
    :abbrev "rpo"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-rps
    :snip "render :partial => \"$${item}\", :status => $${500}"
    :abbrev "rps"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-rt
    :snip "render :text => \"$${Text here...}\""
    :abbrev "rt"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-rtl
    :snip "render :text => \"$${Text here...}\", :layout => \"$${layoutname}\""
    :abbrev "rtl"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-rtlt
    :snip "render :text => \"$${Text here...}\", :layout => $${true}"
    :abbrev "rtlt"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-rts
    :snip "render :text => \"$${Text here...}\", :status => $${401}"
    :abbrev "rts"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-rcea
    :snip "render_component :action => \"$${index}\""
    :abbrev "rcea"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-rcec
    :snip "render_component :controller => \"$${items}\""
    :abbrev "rcec"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-rceca
    :snip "render_component :controller => \"$${items}\", :action => \"$${index}\""
    :abbrev "rceca"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-rea
    :snip "redirect_to :action => \"$${index}\""
    :abbrev "rea"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-reai
    :snip "redirect_to :action => \"$${show}\", :id => $${@item}"
    :abbrev "reai"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-rec
    :snip "redirect_to :controller => \"$${items}\""
    :abbrev "rec"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-reca
    :snip "redirect_to :controller => \"$${items}\", :action => \"$${list}\""
    :abbrev "reca"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-recai
    :snip "redirect_to :controller => \"$${items}\", :action => \"$${show}\", :id => $${@item}"
    :abbrev "recai"
    :abbrev-table ruby-mode-abbrev-table)

  ;; Environment
  (def-snip rails-snip-flash
    :snip "flash[:$${notice}] = \"$${Text here...}\""
    :abbrev "flash"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-logi
    :snip "logger.info \"$${Text here...}\""
    :abbrev "logi"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-par
    :snip "params[:$${id}]"
    :abbrev "par"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-ses
    :snip "session[:$${user}]"
    :abbrev "ses"
    :abbrev-table ruby-mode-abbrev-table)

  ;; model
  (def-snip rails-snip-ar-bt
    :snip "belongs_to :$${model}, :class_name => \"$${class}\", :foreign_key => \"$${key}\""
    :abbrev "bt"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-ar-hm
    :snip "has_many :$${model}, :class_name => \"$${class}\", :foreign_key => \"$${key}\", :dependent => :$${destroy}"
    :abbrev "hm"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-ar-ho
    :snip "has_one :$${model}, :class_name => \"$${class}\", :foreign_key => \"$${key}\", :dependent => :$${destroy}"
    :abbrev "ho"
    :abbrev-table ruby-mode-abbrev-table)

  ;; Validation
  (def-snip rails-snip-ar-vp
    :snip "validates_presence_of :$${attr}"
    :abbrev "vp"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-ar-vu
    :snip "validates_uniqueness_of :$${attr}"
    :abbrev "vu"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-ar-vn
    :snip "validates_numericality_of :$${attr}"
    :abbrev "vn"
    :abbrev-table ruby-mode-abbrev-table)

  ;; Migrations
  (def-snip rails-snip-mct
    :snip "create_table :$${name} do |t|\n$>$.\nend"
    :abbrev "mct"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-mctf
    :snip "create_table :$${name}, :force => true do |t|\n$>$.\nend"
    :abbrev "mctf"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-mdt
    :snip "drop_table :$${name}"
    :abbrev "mdt"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-mtcl
    :snip "t.column \"$${name}\", :$${type}"
    :abbrev "mtcl"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-mac
    :snip "add_column :$${table_name}, :$${column_name}, :$${type}"
    :abbrev "mac"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-mcc
    :snip "change_column :$${table_name}, :$${column_name}, :$${type}"
    :abbrev "mcc"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-mrec
    :snip "rename_column :$${table_name}, :$${column_name}, :$${new_column_name}"
    :abbrev "mrec"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-mrmc
    :snip "remove_column :$${table_name}, :$${column_name}"
    :abbrev "mrmc"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-mai
    :snip "add_index :$${table_name}, :$${column_name}"
    :abbrev "mai"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-mait
    :snip "add_index :$${table_name}, :$${column_name}, :$${index_type}"
    :abbrev "mait"
    :abbrev-table ruby-mode-abbrev-table)

  (def-snip rails-snip-mrmi
    :snip "remove_index :$${table_name}, :$${column_name}"
    :abbrev "mrmi"
     :abbrev-table ruby-mode-abbrev-table))

(defun rails-erb-abbrev-init()
  ;; fix undefuned variable html-mode-abbrev-table
  (unless (boundp 'html-mode-abbrev-table)
    (setq html-mode-abbrev-table (make-abbrev-table)))
  (unless (boundp 'html-helper-mode-abbrev-table)
    (setq html-helper-mode-abbrev-table (make-abbrev-table)))

  (def-snip rails-snip-erb-ft
    :snip "<%= form_tag :action => \"$${update}\" %>\n$.\n<%= end_form_tag %>"
    :abbrev "ft"
    :abbrev-table (html-mode-abbrev-table html-helper-mode-abbrev-table))

  (def-snip rails-snip-erb-lia
    :snip "<%= link_to \"$${title}\", :action => \"$${index}\" %>"
    :abbrev "lia"
    :abbrev-table (html-mode-abbrev-table html-helper-mode-abbrev-table))

  (def-snip rails-snip-erb-liai
    :snip "<%= link_to \"$${title}\", :action => \"$${edit}\", :id => $${@item} %>"
    :abbrev "liai"
    :abbrev-table (html-mode-abbrev-table html-helper-mode-abbrev-table))

  (def-snip rails-snip-erb-lic
    :snip "<%= link_to \"$${title}\", :controller => \"$${items}\" %>"
    :abbrev "lic"
    :abbrev-table (html-mode-abbrev-table html-helper-mode-abbrev-table))

  (def-snip rails-snip-erb-lica
    :snip "<%= link_to \"$${title}\", :controller => \"$${items}\", :action => \"$${index}\" %>"
    :abbrev "lica"
    :abbrev-table (html-mode-abbrev-table html-helper-mode-abbrev-table))

  (def-snip rails-snip-erb-licai
    :snip "<%= link_to \"$${title}\", :controller => \"$${items}\", :action => \"$${edit}\", :id => $${@item} %>"
    :abbrev "licai"
    :abbrev-table (html-mode-abbrev-table html-helper-mode-abbrev-table))

  (def-snip rails-snip-erb-h
    :snip "<% h $${@item} %>"
    :abbrev "%h"
    :abbrev-table (html-mode-abbrev-table html-helper-mode-abbrev-table))

  (def-snip rails-snip-erb-if
    :snip "<% if $${cond} -%>\n$.\n<% end -%>"
    :abbrev "%if"
    :abbrev-table (html-mode-abbrev-table html-helper-mode-abbrev-table))

  (def-snip rails-snip-erb-ifel
    :snip "<% if $${cond} -%>\n$.\n<% else -%>\n<% end -%>"
    :abbrev "%ifel"
    :abbrev-table (html-mode-abbrev-table html-helper-mode-abbrev-table))

  (def-snip rails-snip-erb-unless
    :snip "<% unless $${cond} -%>\n$.\n<% end -%>"
    :abbrev "%unless"
    :abbrev-table (html-mode-abbrev-table html-helper-mode-abbrev-table))

  (def-snip rails-snip-erb-block
    :snip "<% $. -%>"
    :abbrev "%"
    :abbrev-table (html-mode-abbrev-table html-helper-mode-abbrev-table))

  (def-snip rails-snip-erb-echo-block
    :snip "<%= $. %>"
    :abbrev "%%"
    :abbrev-table (html-mode-abbrev-table html-helper-mode-abbrev-table)))

(defun ruby-indent-or-complete ()
  "Complete if point is at end of a word, otherwise indent line."
  (interactive)
  (if snippet
      (snippet-next-field)
    (if (looking-at "\\>")
        (hippie-expand nil)
      (ruby-indent-command))))


(defun ruby-newline-and-indent ()
  (interactive)
  (newline)
  (ruby-indent-command))

(defun rails-switch-to-view()
  (let ((pos (if (functionp 'posn-at-point)
                 (nth 2 (posn-at-point))
               (cons 200 100)))) ; mouse position at point
    (save-excursion
      (let (action path files)
        (goto-char (line-end-position))
        (search-backward-regexp "^[ ]*def \\([a-z_]+\\)")
        (setq action (match-string 1))
        (search-backward-regexp "^[ ]*class \\([a-zA-Z0-9_]+\\(::\\([a-zA-Z0-9_]+\\)\\)?\\)Controller[ ]+<")
        (setq path (rails-inflector-underscore (match-string 1)))
        (setq path (concat "app/views/" path "/"))

        (setq files (directory-files
                     (concat (rails-root) path)
                     nil
                     (concat "^" action (rails-make-template-regex))))

        (if (= 1 (list-length files))
            (progn
              (find-file (concat (rails-root) path (car files)))
              (message (concat path action))))

        (if (< 1 (list-length files))
            (let (items tmp file)
              (setq tmp files)
              (setq items (list))
              (while (car tmp)
                (add-to-list 'items (cons (car tmp) (car tmp)))
                (setq tmp (cdr tmp)))

              (setq file
                    (x-popup-menu
                     (list (list (car pos) (cdr pos))
                           (selected-window))
                     (list "Please select.." (cons "Please select.." items ))))
              (if file
                  (progn
                    (find-file (concat (rails-root) path file))
                    (message (concat path action))))))

        (if (> 1 (list-length files))
            (if (y-or-n-p (format "%s%s not found, create %s.rhtml? " path action action))
                (let ((root (rails-root)))
                  (make-directory (concat root path) t)
                  (find-file (format "%s%s%s.rhtml" root path action)))))))))


(defun rails-switch-to-action()
  (let (file path action root)
    (setq file buffer-file-name)
    (string-match "views/\\([^/]+\\)/\\([^/\.]+\\)\\(/\\([^/\.]+\\)\\)?" file)
    (if (match-beginning 4)
        (progn
          (setq path
                (concat (substring file (match-beginning 1) (match-end 1))
                        "/"
                        (substring file (match-beginning 2) (match-end 2)) ))
          (setq path (concat path "_controller.rb"))
          (setq action (substring file (match-beginning 4) (match-end 4))))
      (progn
        (setq path (concat
                    (substring file (match-beginning 1) (match-end 1))
                    "_controller.rb" ))
        (setq action (substring file (match-beginning 2) (match-end 2))))
      )
    (setq root (rails-root))
    (setq path (concat "app/controllers/" path))
    (if (file-exists-p (concat root path))
        (progn
          (find-file (concat root path))
          (goto-char (point-min))
          (message (concat path "#" action))
          (if (search-forward-regexp (concat "^[ ]*def[ ]*" action))
              (recenter))))))


(defun rails-switch-view-action()
  (interactive)
  (if (string-match "\\.rb$" buffer-file-name)
      (rails-switch-to-view)
    (rails-switch-to-action)))


(defun rails-inflector-underscore (camel-cased-word)
  (let* ((case-fold-search nil)
         (path (replace-regexp-in-string "::" "/" camel-cased-word))
         (path (replace-regexp-in-string "\\([A-Z]+\\)\\([A-Z][a-z]\\)" "\\1_\\2" path))
         (path (replace-regexp-in-string "\\([a-z\\d]\\)\\([A-Z]\\)" "\\1_\\2" path)))
    (downcase path)))


(defun rails-make-template-regex ()
  "Return regex to match rails view templates"
  (let (reg tmp it)
    (setq reg "\\.\\(")
    (setq tmp rails-templates-list)
    (while (setq it (car tmp))
      (progn
        (setq reg (concat reg it))
        (setq tmp (cdr tmp))
        (if (car tmp)
            (setq reg (concat reg "\\|"))
          (setq reg (concat reg "\\)$")))))
    (if reg reg)))


(defun rails-root ()
  "Return RAILS_ROOT"
  (let (curdir max found)
    (setq curdir default-directory)
    (setq max 10)
    (setq found nil)
    (while (and (not found) (> max 0))
      (progn
        (if (file-exists-p (concat curdir "config/environment.rb"))
            (progn
              (setq found t))
          (progn
            (setq curdir (concat curdir "../"))
            (setq max (- max 1))))))
    (if found curdir)))


;; replace in autorevert.el
(defun auto-revert-tail-handler ()
  (let ((size (nth 7 (file-attributes buffer-file-name)))
        (modified (buffer-modified-p))
        buffer-read-only    ; ignore
        (file buffer-file-name)
        buffer-file-name)   ; ignore that file has changed
    (when (> size auto-revert-tail-pos)
      (undo-boundary)
      (save-restriction
        (widen)
        (save-excursion
          (let ((cur-point (point-max)))
            (goto-char (point-max))
            (insert-file-contents file nil auto-revert-tail-pos size)
            (ansi-color-apply-on-region cur-point (point-max)))))
      (undo-boundary)
      (setq auto-revert-tail-pos size)
      (set-buffer-modified-p modified)))
  (set-visited-file-modtime))

(defun rails-open-log (env)
  (let ((root (rails-root)))
    (if root
        (progn
          (if (file-exists-p (concat root "/log/" env ".log"))
              (progn
                (find-file (concat root "/log/" env ".log"))
                (set-buffer-file-coding-system 'utf-8)
                (ansi-color-apply-on-region (point-min) (point-max))
                (set-buffer-modified-p nil)
                (rails-minor-mode t)
                (goto-char (point-max))
                (setq auto-revert-interval 1)
                (setq auto-window-vscroll t)
                (auto-revert-tail-mode t)))))))


(defun rails-webrick-open-browser()
  (interactive)
  (browse-url rails-webrick-url))


(defun rails-webrick-open-buffer()
  (interactive)
  (switch-to-buffer rails-webrick-buffer-name))


(defun rails-webrick-sentinel (proc msg)
  (if (memq (process-status proc) '(exit signal))
        (message
         (concat
          (if rails-use-mongrel "Mongrel" "WEBrick") " stopped"))))


(defun rails-webrick-process-status()
  (let (st)
    (setq st (get-buffer-process rails-webrick-buffer-name))
    (if st t nil)))

(defun rails-webrick-process-stop()
  (interactive)
  (let (proc)
    (setq proc (get-buffer-process rails-webrick-buffer-name))
    (if proc
        (kill-process proc))))


(defun rails-webrick-process(env)
  (let (proc dir root)
    (setq proc (get-buffer-process rails-webrick-buffer-name))
    (unless proc
      (progn
        (setq root (rails-root))
        (if root
            (progn
              (setq dir default-directory)
              (setq default-directory root)
              (if rails-use-mongrel
                  (setq proc
                        (apply 'start-process-shell-command
                               "mongrel_rails"
                               rails-webrick-buffer-name
                               "mongrel_rails"
                               (list "start" "0.0.0.0" rails-webrick-port)))
                (setq proc
                      (apply 'start-process-shell-command
                             rails-ruby-command
                             rails-webrick-buffer-name
                             rails-ruby-command
                             (list (concat root "script/server")
                                   (concat " -e " env)
                                   (concat " -p " rails-webrick-port)))))
              (set-process-filter proc 'rails-webrick-filter)
              (set-process-sentinel proc 'rails-webrick-sentinel)
              (setq default-directory dir)

              (message (concat (if rails-use-mongrel
                                   "Mongrel" "Webrick")
                               "(" env  ") started with port " rails-webrick-port)))
          (progn
            (message "RAILS_ROOT not found")))))))


(defun rails-webrick-filter (process line)
  (let ((buffer (current-buffer)))
    (switch-to-buffer rails-webrick-buffer-name)
    (goto-char(point-min))
    (insert line)
    (switch-to-buffer buffer)))


(defun rails-search-doc (&rest item)
  (interactive)
  (if (or (not (boundp item))
          (not item))
      (setq item (thing-at-point 'sexp)))
  (unless item
    (setq item (read-string "Search symbol? ")))
  (if item
      (let ((buf (buffer-name)))
        (if (and rails-chm-file
                 (file-exists-p rails-chm-file))
            (progn
              (start-process "keyhh" "*keyhh*" "keyhh.exe" "-#klink"
                             (format "'%s'" item)  rails-chm-file))
            (progn
              (unless (string= buf "*ri*")
                (switch-to-buffer-other-window "*ri*"))
              (setq buffer-read-only nil)
              (kill-region (point-min) (point-max))
              (message (concat "Please wait..."))
              (call-process "ri" nil "*ri*" t item)
              (setq buffer-read-only t)
              (local-set-key [return] 'rails-search-doc)
              (goto-char (point-min)))))))


(defun rails-create-tags()
  "Create tags file"
  (interactive)
  (let ((root (rails-root)) dir cmd)
    (message "Creating TAGS, please wait...")
    (setq dir default-directory)
    (setq default-directory root)
    (setq cmd "ctags -e -a --Ruby-kinds=-f -o %s -R %s %s")

    (shell-command (format cmd tags-file-name (concat root "app") (concat root "lib")))

    (setq default-directory dir)
    (visit-tags-table tags-file-name)))


(defun rails-toggle-use-mongrel()
  (interactive)
  (let ((toggle (boundp 'rails-use-mongrel)))
    (setq rails-use-mongrel (not rails-use-mongrel))))


(define-minor-mode rails-minor-mode
  "RubyOnRails"
  nil
  " RoR"
  (list
   (cons [menu-bar] rails-minor-mode-menu-bar-map)
   (cons "\C-t"  'rails-switch-view-action)
   (cons [f1]  'rails-search-doc))

  (abbrev-mode -1)
  (rails-abbrev-init)

  ;; Tags
  (make-local-variable 'tags-file-name)

  (setq tags-file-name (concat (rails-root) "TAGS")))

(add-hook 'ruby-mode-hook
          (lambda()
            (rails-minor-mode t)
            (local-set-key (kbd "C-.") 'complete-tag)
            (if rails-use-another-define-key
                (progn
                  (local-set-key (kbd "TAB") 'ruby-indent-or-complete)
                  (local-set-key (kbd "RET") 'ruby-newline-and-indent))
              (progn
                (local-set-key (kbd "<tab>") 'ruby-indent-or-complete)
                (local-set-key (kbd "<return>") 'ruby-newline-and-indent)))))

(add-hook 'speedbar-mode-hook
          (lambda()
            (speedbar-add-supported-extension "\\.rb")))

(add-hook 'find-file-hooks
          (lambda()
            (if (and (string-match (rails-make-template-regex) buffer-file-name)
                     (rails-root))
                (progn
                  (add-hook 'local-write-file-hooks
                            '(lambda()
                               (save-excursion
                                 (untabify (point-min) (point-max))
                                 (delete-trailing-whitespace))))

                  (rails-minor-mode t)
                  (rails-erb-abbrev-init)
                  (if rails-use-another-define-key
                      (local-set-key "TAB"
                                     '(lambda() (interactive)
                                        (if snippet
                                            (snippet-next-field)
                                          (if (looking-at "\\>")
                                              (hippie-expand nil)
                                            (indent-for-tab-command)))))
                    (local-set-key (kbd "<tab>")
                                   '(lambda() (interactive)
                                      (if snippet
                                          (snippet-next-field)
                                        (if (looking-at "\\>")
                                            (hippie-expand nil)
                                          (indent-for-tab-command))))))))))

(provide 'rails)