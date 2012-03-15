((auto-complete status "installed" recipe
                (:name auto-complete
                       :type git
                       :url "http://github.com/m2ym/auto-complete.git"
                       :load-path "."
                       :post-init
                       (lambda nil
                         (require 'auto-complete)
                         (add-to-list 'ac-dictionary-directories
                                      (expand-file-name "dict" pdir))
                         (require 'auto-complete-config)
                         (ac-config-default))))
 (auto-complete-etags status "installed" recipe
                      (:name auto-complete-etags
                             :type emacswiki))
 (cmake-mode status "installed" recipe
             (:name cmake-mode
                    :type http
                    :url "http://www.cmake.org/CMakeDocs/cmake-mode.el"
                    :features "cmake-mode"))
 (coffee-mode status "installed" recipe
              (:name coffee-mode
                     :type git
                     :url "https://github.com/defunkt/coffee-mode.git"
                     :features coffee-mode
                     :post-init
                     (lambda nil
                       (add-to-list 'auto-mode-alist
                                    '("\\.coffee$" . coffee-mode))
                       (add-to-list 'auto-mode-alist
                                    '("Cakefile" . coffee-mode))
                       (setq coffee-js-mode 'javascript-mode))))
 (csv-mode status "installed" recipe
           (:name csv-mode
                  :type http
                  :url "http://centaur.maths.qmul.ac.uk/Emacs/files/csv-mode.el"))
 (ecb status "required" recipe
      (:name ecb
             :type cvs
             :module "ecb"
             :url ":pserver:anonymous@ecb.cvs.sourceforge.net:/cvsroot/ecb"
             :build
             ((concat "make CEDET=" " EMACS=" el-get-emacs))))
 (el-get status "installed" recipe
         (:name el-get
                :type git
                :url "https://github.com/dimitri/el-get.git"
                :features el-get
                :load "el-get.el"
                :compile "el-get.el")))
