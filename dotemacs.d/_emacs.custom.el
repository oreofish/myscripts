(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(Info-additional-directory-list (quote ("~/.emacs.d/site-lisp/cedet/cogre/" "~/.emacs.d/site-lisp/cedet/ede/" "~/.emacs.d/site-lisp/cedet/eieio/" "~/.emacs.d/site-lisp/cedet/semantic/doc/" "~/.emacs.d/site-lisp/cedet/speedbar/" "~/.emacs.d/site-lisp/ecb/info-help/" "~/.emacs.d/info/" "~/.emacs.d/site-lisp/nxml/")))
 '(bsh-jar "~/.emacs.d/jde/java/lib/bsh.jar")
 '(completion-ignored-extensions (quote ("CVS/" ".cache" ".o" "~" ".bin" ".bak" ".obj" ".map" ".a" ".ln" ".blg" ".bbl" ".elc" ".lof" ".glo" ".idx" ".lot" ".dvi" ".fmt" ".tfm" ".pdf" ".class" ".fas" ".lib" ".x86f" ".sparcf" ".lo" ".la" ".toc" ".log" ".aux" ".cp" ".fn" ".ky" ".pg" ".tp" ".vr" ".cps" ".fns" ".kys" ".pgs" ".tps" ".vrs" ".svn/")))
 '(current-language-environment "UTF-8")
 '(default-tab-width 4 t)
 '(ecb-options-version "2.31")
 '(erc-prompt-for-password nil)
 '(fuel-listener-factor-binary "/Applications/factor/Factor.app/Contents/MacOS/factor")
 '(fuel-listener-factor-image "/Applications/factor/factor.image")
 '(grep-command "grep -nH -r -e *")
 '(ido-enable-flex-matching t)
 '(indent-tabs-mode nil)
 '(inferior-erlang-machine "erl" t)
 '(inferior-erlang-machine-options (quote ("-sname" "orpheus-emacs")) t)
 '(jde-ant-args "-emacs" t)
 '(jde-ant-read-target t)
 '(jde-ant-send-buffer nil t)
 '(jde-complete-unique-method-names t)
 '(jde-electric-return-p t)
 '(jde-enable-abbrev-mode t)
 '(jde-gen-buffer-boilerplate (quote ("/**" " * Copyright (c) 2011, Ola Bini <ola.bini@gmail.com>" " * All rights reserved." " * " " * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:" " * " " * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer." " * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer" " * in the documentation and/or other materials provided with the distribution." " * " " * Neither the name of the IT-Centrum, Karolinska Institutet, Sweden nor the names of its contributors may be used to endorse or" " * promote products derived from this software without specific prior written permission." " * " " * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES," " * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED." " * IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR" " * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;" " * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR" " * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE." " */")))
 '(jde-gen-cflow-enable t)
 '(jde-gen-conditional-padding-1 "")
 '(jde-gen-conditional-padding-3 " ")
 '(jde-gen-get-set-var-template (quote ("(jde-gen-insert-at-class-top nil t)" "(progn (tempo-save-named 'mypos (point-marker)) nil)" "(progn" "  (jde-gen-get-next-member-pos '(\"private\")) nil)" "(P \"Variable type: \" type t)" "(P \"Variable name: \" name t)" "'&'n'>" "(progn (require 'jde-javadoc) (jde-javadoc-insert-start-block))" "\"* Describe \" (s name) \" here.\" '>'n" "'> (jde-javadoc-insert-end-block)" "'& \"private \" (s type) \" \"" "(s name) \";\" '>" "(progn (goto-char (marker-position (tempo-lookup-named 'mypos))) nil)" "(jde-gen-blank-lines 2 -1)" "'> (jde-javadoc-insert-start-block)" "\"* Get the <code>\" (jde-gen-lookup-and-capitalize 'name) \"</code> value.\" '>'n" "'> (jde-javadoc-insert-empty-line)" "'>" "(let ((type (tempo-lookup-named 'type)))" "  (jde-gen-save-excursion (jde-javadoc-insert 'tempo-template-jde-javadoc-return-tag)))" "'> (jde-javadoc-insert-end-block)" "(jde-gen-method-signature" "  \"public\"" "  (jde-gen-lookup-named 'type)" "  (if (string= \"boolean\" (jde-gen-lookup-named 'type) ) " "    (concat \"is\" (jde-gen-lookup-and-capitalize 'name))" "   (concat \"get\" (jde-gen-lookup-and-capitalize 'name)))" "  nil" " )" "(jde-gen-electric-brace)" "\"return \" (s name) \";\" '>'n \"}\"'>'n" "'n" "'> (jde-javadoc-insert-start-block)" "\"* Set the <code>\" (jde-gen-lookup-and-capitalize 'name) \"</code> value.\" '>'n" "\"*\" '>'n" "\"* @param new\" (jde-gen-lookup-and-capitalize 'name)" "\" The new \" (jde-gen-lookup-and-capitalize 'name) \" value.\" '>'n" "'> (jde-javadoc-insert-end-block)" "(jde-gen-method-signature " "  \"public\"" "  \"void\"" "  (concat \"set\" (jde-gen-lookup-and-capitalize 'name))" "  (concat \"final \" (jde-gen-lookup-named 'type) \" new\" " "          (jde-gen-lookup-and-capitalize 'name))" " )" "(jde-gen-electric-brace)" "'>\"this.\" (s name) \" = new\" (jde-gen-lookup-and-capitalize 'name)" "\";\" '>'n \"}\" '>" "(when (looking-at \"\\\\s-*\\n\\\\s-*$\")" "  (forward-line 1) (end-of-line) nil)")))
 '(jde-gen-main-method-template (quote ("(jde-gen-save-excursion" " (jde-wiz-gen-method" "   \"public static\"" "   \"void\"" "   \"main\"" "   \"final String[] args\"" "   \"\" \"\"))" ";; don't move point" "(setq tempo-marks nil)")))
 '(jde-import-auto-sort t)
 '(jde-jdk (quote ("1.6.0")))
 '(jde-jdk-registry (quote (("1.6.0" . "/System/Library/Frameworks/JavaVM.framework/Versions/1.6.0/"))))
 '(nxml-auto-insert-xml-declaration-flag t)
 '(nxml-slash-auto-complete-flag t)
 '(rails-tags-command "ctags -e -a --Ruby-kinds=-f -o %s -R %s")
 '(semanticdb-default-save-directory "~/.emacs.d/semantic/")
 '(tab-width 4)
 '(x-select-enable-clipboard t))


(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(ioke-font-lock-kind-face ((((class color)) (:foreground "BlueViolet"))))
 '(ioke-font-lock-known-kind-face ((((class color)) (:foreground "DarkRed"))))
 '(ioke-font-lock-operator-name-face ((((class color)) (:foreground "CornflowerBlue"))))
 '(ioke-font-lock-operator-symbol-face ((((class color)) (:foreground "deep sky blue"))))
 '(ioke-font-lock-symbol-face ((((class color)) (:foreground "SlateGray4"))))
 '(jde-java-font-lock-api-face ((((class color)) (:foreground "DarkRed"))))
 '(jde-java-font-lock-constant-face ((((class color)) (:foreground "BlueViolet"))))
 '(jde-java-font-lock-package-face ((((class color)) (:foreground "SlateGray4"))))
 '(nxml-delimited-data-face ((nil (:foreground "gray"))))
 '(nxml-name-face ((nil (:foreground "#33aaff")))))

(provide 'emacs-custom)
