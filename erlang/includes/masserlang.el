;;; masserlang --- Summary
;;; Commentary:
;;; masse's erlang setup
;;; Code:

(add-to-list 'load-path "/root/distel/elisp")

(require 'align)
(require 'erlang-start)
(require 'flycheck-rebar3)
(require 'company)
(require 'company-distel)

(distel-setup)
(add-to-list 'company-backends 'company-distel-modules)
(setq company-require-match nil)

(set-variable 'erlang-electric-commands nil)
(setq safe-local-variable-values
      (quote ((erlang-indent-level . 4)
              (erlang-indent-level . 2))))

(flycheck-rebar3-setup)
(flycheck-define-checker erlang
  "awesome erlang checker"
  :command ("erlc"
            "-o" temporary-directory
            (option-list "-I" flycheck-erlang-include-path)
            (option-list "-pa" flycheck-erlang-library-path)
            "-Wall"
            source)
  :error-patterns
  ((warning line-start (file-name) ":" line ": Warning:" (message) line-end)
   (error line-start (file-name) ":" line ": " (message) line-end))
  :modes erlang-mode
  :predicate (lambda ()
               (string-suffix-p ".erl" (buffer-file-name))))
(setq flycheck-erlang-include-path '("../include"))
(setq flycheck-erlang-library-path '("../_build/default/lib/*/ebin"))

(defun my-erlang-mode-hook ()
  "We want company mode."
  (company-mode t))

(add-hook 'erlang-mode-hook 'my-erlang-mode-hook)

(defun my-erlang-new-file-hook ()
  "Insert my very own erlang file header."
  (interactive)
  (insert "%% -*- mode: erlang; erlang-indent-level: 4 -*-\n")
  (insert (concat "-module(" (erlang-get-module-from-file-name) ").\n\n"))
  (insert (concat "-export([]).\n\n")))

(add-hook 'erlang-new-file-hook 'my-erlang-new-file-hook)

;; make hack for compile command
;; uses Makefile if it exists, else looks for ../inc & ../ebin
(unless (null buffer-file-name)
  (make-local-variable 'compile-command)
  (setq compile-command
        (cond ((file-exists-p "Makefile")  "make -k")
              ((file-exists-p "../Makefile")  "make -kC..")
              (t (concat
                  "erlc "
                  (if (file-exists-p "../ebin") "-o ../ebin " "")
                  (if (file-exists-p "../include") "-I ../include " "")
                  "+debug_info -W " buffer-file-name)))))

(provide 'masserlang)

;;; masserlang.el ends here
