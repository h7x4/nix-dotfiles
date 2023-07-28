;;; ~/.emacs.d/config.el -*- lexical-binding: t; -*-

; (setq user-emacs-directory (substitute-in-file-name "$HOME/.emacs.d"))

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package general
  :config
  (general-evil-setup)

  (general-create-definer leader-key
    ; :states 'normal
    :states 'motion
    :prefix "SPC"
		:non-normal-prefix "C-SPC"))

(leader-key
  ""     nil
  "c"   (general-simulate-key "C-c" :which-key "C-c")
  "u"   (general-simulate-key "C-u" :which-key "C-u")
  "x"   (general-simulate-key "C-x" :which-key "C-x")
  
  "m"   '(:ignore t :which-key "mode")
  "mx"  'nil
  
  ;; Help
  "h"   (general-simulate-key "<f1>" :which-key "C-h")
  
  ;; Insert
  "i"   '(:ignore t :which-key "C-h")
  "ix"  'nil

  ;; Package manager
  ;; "p"   '(:ignore t :which-key "packages")
  ;; "pl"  'list-packages

  ;; Quit operations
  "q"	  '(:ignore t :which-key "quit emacs")
  "qq"  'kill-emacs
  "qz"  'delete-frame

  ;; Buffer operations
  "b"   '(:ignore t :which-key "buffer")
  "bb"  'mode-line-other-buffer
  "bk"  'kill-this-buffer
  ;; "bn"  'next-buffer
  ;; "bp"  'previous-buffer
  "bq"  'kill-buffer-and-window
  ;; "bR"  'rename-file-and-buffer
  "br"  'revert-buffer

  ;; Window operations
  "w"   '(:ignore t :which-key "window")
  "wm"  'maximize-window
  "wh"  'split-window-horizontally
  "wg"  'split-window-vertically
  ;; "wu"  'winner-undo
  "ww"  'other-window
  "wk"  'delete-window
  "wD"  'delete-other-windows

  ;; File operations
  "f"   '(:ignore t :which-key "find")
  ; "fc"  'write-file
  ; "fe"  '(:ignore t :which-key "emacs")
  ;; "fed" 'find-user-init-file
  ;; "feR" 'load-user-init-file
  ; "fj"  'dired-jump
  "fl"  'find-file-literally
  ;; "fR"  'rename-file-and-buffer
  "fs"  'save-buffer

  ;; Applications
  "a"   '(:ignore t :which-key "apps")
  "ad"  'dired
  ":"   'shell-command
  ";"   'eval-expression
  "ac"  'calendar
  "oa"  'org-agenda)

; (global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(general-define-key
  "<escape>" 'keyboard-escape-quit
  "C-o" 'previous-buffer
  "C-p" 'next-buffer)

(setq use-dialog-box nil)

;; (desktop-save-mode 1)

(setq-default
  tab-width 2
  c-basic-offset 2)

(setq backup-directory-alist
  `(("." . ,(concat user-emacs-directory "/temp"))))

(use-package evil
  :demand t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)

  :general ; (leader-key
    ; "wh" '(evil-window-left  :which-key "←")
    ; "wj" '(evil-window-down  :which-key "↓")
    ; "wk" '(evil-window-up    :which-key "↑")
    ; "wl" '(evil-window-right :which-key "→")) 
  ([remap evil-ex-search-forward] 'swiper)
  ([remap evil-ex-search-backward] 'swiper-backward)

  :bind (
    ("C-h" . evil-window-left)
    ("C-j" . evil-window-down)
    ("C-k" . evil-window-up)
    ("C-l" . evil-window-right)

    :map evil-insert-state-map
      ("C-g" . evil-normal-state)
      ("C-h" . evil-delete-backward-char-and-join))

  :config

	  ;; :q should kill the current buffer rather than quitting emacs entirely
	  (evil-ex-define-cmd "q" 'kill-this-buffer)
	  ;; Need to type out :quit to close emacs
	  (evil-ex-define-cmd "quit" 'evil-quit)

    (evil-set-initial-state 'messages-buffer-mode 'normal)
    (evil-set-initial-state 'dashboard-mode 'normal)

    (evil-mode 1))

(use-package evil-collection
  :after (evil)
  :config
    (evil-collection-init)
    (evil-collection-company-setup))

(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines)
  :general (leader-key
    "c" '(evilnc-comment-or-uncomment-lines :which-key "/* */"))
  (general-nmap
    "gc" 'evilnc-comment-operator))

;; (use-package evil-escape
;;   :after (evil company)
;;   :diminish evil-escape-mode
;;   :init
;;     (with-eval-after-load 'company
;;      (add-hook 'evil-normal-state-entry-hook #'company-cancel))
;;     (setq evil-escape-key-sequence "jk"
;;          evil-escape-unordered-key-sequence t)
;;   :config
;;   (evil-escape-mode))

(use-package ivy

  :bind (
    :map ivy-minibuffer-map
    ("M-j" . ivy-next-line)
    ("M-k" . ivy-previous-line)
    ("M-l" . ivy-alt-done)))

(use-package ivy-rich
  :config (ivy-rich-mode 1))

(use-package counsel
  :general (leader-key
    "ff"    '(counsel-find-file :which-key "find file")
    "f SPC" '(counsel-ag :which-key "Ag")
    "ik"    '(counsel-yank-pop :which-key "from kill-ring")
    "bb"    '(counsel-ibuffer :which-key "choose buffer")
    "fe"    '(counsel-flycheck :which-key "find error"))
  
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
           ("C-r" . 'counsel-minibuffer-history)))

(use-package org
	:general (leader-key
		"o"   '(:ignore t :which-key "org")
		"oa"  '(org-agenda :which-key "agenda")
		"ox"  '(org-toggle-checkbox :which-key "[X]")
		"oe"  '(org-edit-src-code :which-key "Edit SRC")
		; Insert
		"io"  '(:ignore t :which-key "org")
		"ios" 'org-insert-structure-template)
  :config
	  (setq org-src-tab-acts-natively nil)
    (org-babel-do-load-languages
      'org-babel-load-languages
      '((dot . t))))

(use-package org-superstar
  :hook (org-mode-hook . org-superstar-mode)
  :config  
    (setq org-startup-indented t)            ;; Indent according to section
    (setq org-startup-with-inline-images t)) ;; Display images in-buffer by default

(use-package evil-org
  :after (evil org)
  :hook
    (org-mode-hook . evil-org-mode)
    (evil-org-mode-hook .  (lambda ()
              (evil-org-set-key-theme '(navigation insert textobjects additional calendar))))
  :config
    (require 'evil-org-agenda)
    (evil-org-agenda-set-keys)

    (setq org-agenda-files '("~/org/agenda.org"))
    (setq org-directory "~/org/"))

(defvar notes-folder "~/.emacs.d/notes")

(defun format-note-path (project-root)
  (concat notes-folder (string-remove-suffix "/" (string-remove-prefix (getenv "HOME") project-root)) ".org"))

(defun get-notes ()
  (interactive)
  (if (projectile-project-p)
	  (let
		  ((note-path (format-note-path (projectile-project-root))))
      (unless (file-exists-p note-path)
			  (when (y-or-n-p (format "%s does not exist. Create it?" note-path))
          (make-directory (file-name-directory note-path) t)
          (make-empty-file note-path)))
      (find-file note-path))
		;; else
    (message "Couldn't find project folder")))

(leader-key
  "fn" '(get-notes :which-key "Get project notes"))

(setq dotfiles '(
  ("Emacs"           . (concat (or (getenv "NIX_DOTFILES") "~/nix") "/home/programs/emacs/config.org"))
  ("Xmonad"          . "$HOME/.xmonad/xmonad.hs")
  ("Xmobar"          . "$XDG_CONFIG_HOME/xmobar/xmobarrc")
  ("Awesome"         . "$XDG_CONFIG_HOME/awesome/rc.lua")
  ("Stalonetray"     . "$HOME/.stalonetrayrc")
  ("Termite"         . "$XDG_CONFIG_HOME/termite/config")
  ("Kitty"           . "$XDG_CONFIG_HOME/kitty/kitty.conf")
  ("Mpd"             . "$XDG_CONFIG_HOME/mpd/mpd.conf")
  ("Ncmpcpp"         . "$HOME/.ncmpcpp/config")
  ("Nnn"             . "$XDG_CONFIG_HOME/nnn/")
  ("TeX-ntnu"        . "$HOME/texmf/tex/latex/local/ntnu.sty")
  ("Tmux"            . "$XDG_CONFIG_HOME/tmux/tmux.conf")
  ("Todo"            . "$HOME/.todo")
  ("Qutebrowser"     . "$XDG_CONFIG_HOME/qutebrowser/config.py")
  ("Vim"             . "$XDG_CONFIG_HOME/nvim/init.lua")
  ("Zsh"             . "$XDG_CONFIG_HOME/zsh/.zshrc")
  ("Config-selector" . "$HOME/.scripts/rofi/config-selector")
  ("Configfiles"     . "$HOME/.scripts/rofi/configfiles")))
  
(defun find-config-file ()
  "Chooses a config-file from dotfiles and opens it in a new buffer"
  (interactive)
  (ivy-read "Config: " dotfiles
    :action (lambda (confpair) (find-file (substitute-in-file-name (eval (cdr confpair)))))))

(leader-key "fc" '(find-config-file :which-key "find config file"))

(use-package monokai-theme
	:config
	(setq monokai-user-variable-pitch t)
	(progn

		(defvar after-load-theme-hook nil
			"Hook run after a color theme is loaded using `load-theme'.")

		(defadvice load-theme (after run-after-load-theme-hook activate)
			"Run `after-load-theme-hook'."
			(run-hooks 'after-load-theme-hook))

		(defun customize-monokai ()
			"Customize monokai theme"
			(if (member 'monokai custom-enabled-themes)
					(custom-theme-set-faces
					 'monokai
					 '(py-object-reference-face ((t (:foreground "#FFA500"))))
					 '(py-decorators-face ((t (:foreground "#FFA500"))))
					 '(py-variable-name-face ((t (:foreground "#FFA500"))))
					 '(py-exception-name-face ((:foreground "#FFA500")))
					 '(py-class-name-face ((:foreground "#FFA500")))
					 '(py-pseudo-keyword-face ((:foreground "#FFA500")))
					 '(py-builtins-face ((:foreground "#FFA500"))))))

		(add-hook 'after-load-theme-hook 'customize-monokai)))

(load-theme 'monokai t)

(use-package centaur-tabs
	:demand
	:config
	(setq
		centaur-tabs-set-icons t
		centaur-tabs-gray-out-icons 'buffer
		centaur-tabs-height 32
		centaur-tabs-set-modified-marker t
		centaur-tabs-modified-marker "•"
		centaur-tabs-set-bar 'under
		x-underline-at-descent-line t
		centaur-tabs-style "wave")

	(centaur-tabs-headline-match)
	(centaur-tabs-mode t)

	; TODO: configure centaur-tabs-active-bar-face and colors

	:general (leader-key
		"bg" '(centaur-tabs-counsel-switch-group :which-key "choose tab group")
		"b M-p" '(centaur-tabs-backward-group :which-key "previous group")
		"b M-n" '(centaur-tabs-forward-group :which-key "next group")
		"bp" '(centaur-tabs-backward-tab :which-key "previous tab")
		"bn" '(centaur-tabs-forward-tab :which-key "next tab")))

(defun centaur-tabs-hide-tab (x)
  "Do no to show buffer X in tabs."
  (let ((name (format "%s" x)))
    (or
     ;; Current window is not dedicated window.
     (window-dedicated-p (selected-window))

     ;; Buffer name not match below blacklist.
     (string-prefix-p "*epc" name)
     (string-prefix-p "*helm" name)
     (string-prefix-p "*Helm" name)
     (string-prefix-p "*Compile-Log*" name)
     (string-prefix-p "*lsp" name)
     (string-prefix-p "*company" name)
     (string-prefix-p "*Flycheck" name)
     (string-prefix-p "*tramp" name)
     (string-prefix-p " *Mini" name)
     (string-prefix-p "*help" name)
     (string-prefix-p "*straight" name)
     (string-prefix-p " *temp" name)
     (string-prefix-p "*Help" name)
     (string-prefix-p "*mybuf" name)

     ;; Is not magit buffer.
     (and (string-prefix-p "magit" name)
	  (not (file-name-extension name)))
     )))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :config
    ;; How tall the mode-line should be. It's only respected in GUI.
    ;; If the actual char height is larger, it respects the actual height.
    (setq doom-modeline-height 25)
    
    ;; How wide the mode-line bar should be. It's only respected in GUI.
    (setq doom-modeline-bar-width 3)
    
    ;; The limit of the window width.
    ;; If `window-width' is smaller than the limit, some information won't be displayed.
    (setq doom-modeline-window-width-limit fill-column)
    
    ;; How to detect the project root.
    ;; The default priority of detection is `ffip' > `projectile' > `project'.
    ;; nil means to use `default-directory'.
    ;; The project management packages have some issues on detecting project root.
    ;; e.g. `projectile' doesn't handle symlink folders well, while `project' is unable
    ;; to hanle sub-projects.
    ;; You can specify one if you encounter the issue.
    (setq doom-modeline-project-detection 'project)
    
    ;; Determines the style used by `doom-modeline-buffer-file-name'.
    ;;
    ;; Given ~/Projects/FOSS/emacs/lisp/comint.el
    ;;   auto => emacs/lisp/comint.el (in a project) or comint.el
    ;;   truncate-upto-project => ~/P/F/emacs/lisp/comint.el
    ;;   truncate-from-project => ~/Projects/FOSS/emacs/l/comint.el
    ;;   truncate-with-project => emacs/l/comint.el
    ;;   truncate-except-project => ~/P/F/emacs/l/comint.el
    ;;   truncate-upto-root => ~/P/F/e/lisp/comint.el
    ;;   truncate-all => ~/P/F/e/l/comint.el
    ;;   truncate-nil => ~/Projects/FOSS/emacs/lisp/comint.el
    ;;   relative-from-project => emacs/lisp/comint.el
    ;;   relative-to-project => lisp/comint.el
    ;;   file-name => comint.el
    ;;   buffer-name => comint.el<2> (uniquify buffer name)
    ;;
    ;; If you are experiencing the laggy issue, especially while editing remote files
    ;; with tramp, please try `file-name' style.
    ;; Please refer to https://github.com/bbatsov/projectile/issues/657.
    (setq doom-modeline-buffer-file-name-style 'relative-to-project)
    
    ;; Whether display icons in the mode-line.
    ;; While using the server mode in GUI, should set the value explicitly.
    (setq doom-modeline-icon (display-graphic-p))
    
    ;; Whether display the icon for `major-mode'. It respects `doom-modeline-icon'.
    (setq doom-modeline-major-mode-icon nil)
    
    ;; Whether display the colorful icon for `major-mode'.
    ;; It respects `all-the-icons-color-icons'.
    (setq doom-modeline-major-mode-color-icon nil)
    
    ;; Whether display the icon for the buffer state. It respects `doom-modeline-icon'.
    (setq doom-modeline-buffer-state-icon t)
    
    ;; Whether display the modification icon for the buffer.
    ;; It respects `doom-modeline-icon' and `doom-modeline-buffer-state-icon'.
    (setq doom-modeline-buffer-modification-icon t)
    
    ;; Whether to use unicode as a fallback (instead of ASCII) when not using icons.
    (setq doom-modeline-unicode-fallback nil)
    
    ;; Whether display the minor modes in the mode-line.
    (setq doom-modeline-minor-modes nil)
    
    ;; If non-nil, a word count will be added to the selection-info modeline segment.
    (setq doom-modeline-enable-word-count nil)
    
    ;; Major modes in which to display word count continuously.
    ;; Also applies to any derived modes. Respects `doom-modeline-enable-word-count'.
    ;; If it brings the sluggish issue, disable `doom-modeline-enable-word-count' or
    ;; remove the modes from `doom-modeline-continuous-word-count-modes'.
    (setq doom-modeline-continuous-word-count-modes '(markdown-mode gfm-mode org-mode))
    
    ;; Whether display the buffer encoding.
    (setq doom-modeline-buffer-encoding t)
    
    ;; Whether display the indentation information.
    (setq doom-modeline-indent-info nil)
    
    ;; If non-nil, only display one number for checker information if applicable.
    (setq doom-modeline-checker-simple-format t)
    
    ;; The maximum number displayed for notifications.
    (setq doom-modeline-number-limit 99)
    
    ;; The maximum displayed length of the branch name of version control.
    (setq doom-modeline-vcs-max-length 12)
    
    ;; Whether display the workspace name. Non-nil to display in the mode-line.
    (setq doom-modeline-workspace-name t)
    
    ;; Whether display the perspective name. Non-nil to display in the mode-line.
    (setq doom-modeline-persp-name t)
    
    ;; If non nil the default perspective name is displayed in the mode-line.
    (setq doom-modeline-display-default-persp-name nil)
    
    ;; If non nil the perspective name is displayed alongside a folder icon.
    (setq doom-modeline-persp-icon t)
    
    ;; Whether display the `lsp' state. Non-nil to display in the mode-line.
    (setq doom-modeline-lsp t)
    
    ;; Whether display the GitHub notifications. It requires `ghub' package.
    (setq doom-modeline-github nil)
    
    ;; The interval of checking GitHub.
    (setq doom-modeline-github-interval (* 30 60))
    
    ;; Whether display the modal state icon.
    ;; Including `evil', `overwrite', `god', `ryo' and `xah-fly-keys', etc.
    (setq doom-modeline-modal-icon nil)
    
    ;; Whether display the mu4e notifications. It requires `mu4e-alert' package.
    (setq doom-modeline-mu4e nil)
    
    ;; Whether display the gnus notifications.
    (setq doom-modeline-gnus t)
    
    ;; Whether gnus should automatically be updated and how often (set to 0 or smaller than 0 to disable)
    (setq doom-modeline-gnus-timer 2)
    
    ;; Whether groups should be excludede when gnus automatically being updated.
    (setq doom-modeline-gnus-excluded-groups '("dummy.group"))
    
    ;; Whether display the IRC notifications. It requires `circe' or `erc' package.
    (setq doom-modeline-irc t)
    
    ;; Function to stylize the irc buffer names.
    (setq doom-modeline-irc-stylize 'identity)
    
    ;; Whether display the environment version.
    (setq doom-modeline-env-version t)
    ;; Or for individual languages
    (setq doom-modeline-env-enable-python t)
    (setq doom-modeline-env-enable-ruby t)
    (setq doom-modeline-env-enable-perl t)
    (setq doom-modeline-env-enable-go t)
    (setq doom-modeline-env-enable-elixir t)
    (setq doom-modeline-env-enable-rust t)
    
    ;; Change the executables to use for the language version string
    (setq doom-modeline-env-python-executable "python") ; or `python-shell-interpreter'
    (setq doom-modeline-env-ruby-executable "ruby")
    (setq doom-modeline-env-perl-executable "perl")
    (setq doom-modeline-env-go-executable "go")
    (setq doom-modeline-env-elixir-executable "iex")
    (setq doom-modeline-env-rust-executable "rustc")
    
    ;; What to dispaly as the version while a new one is being loaded
    (setq doom-modeline-env-load-string "...")
    
    ;; Hooks that run before/after the modeline version string is updated
    (setq doom-modeline-before-update-env-hook nil)
    (setq doom-modeline-after-update-env-hook nil))
  
(column-number-mode)

(set-face-attribute 'default nil
                    :family "Fira Code"
            		    :height 130
                    :weight 'normal
                    :width 'normal)

; (setq doom-font (font-spec :family "Fira Code" :size 16 :weight 'regular)
;       doom-variable-pitch-font (font-spec :family "Droid Sans" :size 13)
;       doom-big-font (font-spec :family "Droid Sans" :size 16)) ;; Presentations or streaming

(set-fontset-font (frame-parameter nil 'font)
  'japanese-jisx0208
  '("Droid Sans Japanese" . "unicode-bmp"))

(use-package fira-code-mode
  :custom (fira-code-mode-disabled-ligatures '("x", "[]"))
  :hook prog-mode)

(use-package dashboard
    :init
    (setq dashboard-set-heading-icons t)
    (setq dashboard-set-file-icons t) 

    (setq dashboard-image-banner-max-height (/ (frame-pixel-height) 3))
    (setq dashboard-startup-banner (concat user-emacs-directory "/logo.svg"))
    ; (setq dashboard-startup-banner (concat user-emacs-directory "/logo.svg"))
    (setq dashboard-center-content t)
    (setq dashboard-items '((recents  . 10)
                            (projects . 5)
                            (agenda . 5)
                            (bookmarks . 10)))
    (setq dashboard-projects-switch-function 'counsel-projectile-switch-project-by-name)

    (dashboard-setup-startup-hook)
    
    :custom
    ; (dashboard-banner-logo-title "Execution >> Idea")
    (dashboard-banner-logo-title "Emacs")

    :config
    (set-face-attribute 'dashboard-banner-logo-title nil :font "Droid Sans" :height 300))

(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)

(global-display-line-numbers-mode)
(setq 
  display-line-numbers-type 'relative
  scroll-margin 5)

;; Disable line numbers for some modes
(dolist (mode '(term-mode-hook
                shell-mode-hook
	              treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))
  


(setq display-line-numbers-type 'relative)
(setq evil-normal-state-cursor '(box "#66d9ef")
      evil-insert-state-cursor '(bar "#a6e22e")
      evil-visual-state-cursor '(hollow "orange"))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(defun lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode)
  
  (general-nmap
    "gr" 'lsp-find-references
    "gd" 'lsp-find-definition
    "gf" 'find-file-at-point))

(use-package lsp-mode
  :commands (lsp lsp-deferred)

  :hook (
    (lsp-mode . lsp-mode-setup)
    (lsp-mode . lsp-enable-which-key-integration))

  :init (setq
		lsp-keymap-prefix "C-c l"
    lsp-completion-provider :capf)

  :config (setq
    lsp-inhibit-message t
    lsp-eldoc-render-all nil
    lsp-enable-file-watchers t
    lsp-enable-snippet t
    lsp-enable-symbol-highlighting t
    lsp-headerline-breadcrumb-enable t
    lsp-highlight-symbol-at-point t
    lsp-modeline-code-actions-enable t
    lsp-modeline-diagnostics-enable t

		lsp-ui-doc-position 'right
		lsp-ui-doc-max-height 40
		lsp-ui-doc-enable nil
		lsp-ui-sideline-delay 0.05
		lsp-ui-sideline-show-code-actions nil)
    (lsp-enable-which-key-integration t)

		(add-to-list 'company-backends '(company-capf company-dabbrev))

	:bind (
    :map lsp-mode-map 
		("M-RET" . lsp-execute-code-action))

  :general (leader-key
    "l"   (general-simulate-key "C-c l" :which-key "LSP"))

 ([remap xref-find-references] #'lsp-ui-peek-find-references)
 ([remap xref-find-definitions] 'lsp-ui-peek-find-definitions)

	(leader-key
		"j"  '(:ignore t :which-key "LSP OWN")
		"ja" 'lsp-format-buffer
		"jf" 'lsp-format-buffer
		"jh" 'lsp-describe-thing-at-point
		"jr" 'lsp-restart-workspace
		"jd" 'lsp-goto-implementation
		"jt" 'lsp-goto-type-definition
	  "jx" 'lsp-ui-doc-mode
		"j <f2>" 'lsp-rename)

 (general-nmap
	 "K" 'lsp-ui-doc-glance))

(use-package lsp-ui)

(use-package lsp-treemacs
  :after (lsp treemacs)
  :hook (lsp-mode . lsp-treemacs-sync-mode))

(use-package lsp-ivy
  :after lsp
  :commands lsp-ivy-workspace-symbol)

(use-package company
  :init (setq
    company-idle-delay 0.1          ; show autocompletion after n seconds
    company-async-timeout 15        ; completion may be slow
		company-tooltip-idle-delay 0.1
    company-minimum-prefix-length 1 ; show suggestions after only one character (insted of several)
    company-tooltip-align-annotations t)

  (add-to-list 'company-backends 'company-files)

  :hook (prog-mode . company-mode)

  :bind (("C-RET" . counsel-company)
          :map prog-mode-map
            ("C-i"     . company-indent-or-complete-common)
            ("C-;"     . counsel-company)
            ("C-M-i"   . counsel-company)
          :map company-active-map
            ; ("C-o"     . company-search-kill-others)
            ; ("C-h"     . company-quickhelp-manual-begin)
            ("C-h"     . company-show-doc-buffer)
            ("C-s"     . company-search-candidates)
            ("M-s"     . company-filter-candidates)
            ([C-tab]   . company-complete-common-or-cycle)
            ([tab]     . company-complete-common-or-cycle)
            ([backtab] . company-select-previous)
            ;; ("M-RET"   . company-complete-selection)
            ("RET"     . company-complete-selection)
          :map company-search-map
            ;; ("M-j"     . company-select-next)
            ;; ("M-k"     . company-select-previous)
            ("C-p"     . company-select-next-or-abort)
            ("C-n"     . company-select-previous-or-abort))
            ;; ("C-n" . 'company-search-repeat-forward)
            ;; ("C-p" . 'company-search-repeat-backward)))
            ;; ("<esc>" . (cmd! (company-search-abort) (company-filter-candidates)))))
  :config
    (general-define-key
      "C-SPC" 'company-capf))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package flycheck
  :config
  (setq
    flycheck-highlighting-mode 'lines)
	
	(set-face-attribute 'flycheck-error nil
                      :family "Fira Code"
											:background "#773131"
                      :weight 'normal
                      :width 'normal)

	(set-face-attribute 'flycheck-warning nil
                      :family "Fira Code"
											:background "#767731"
                      :weight 'normal
                      :width 'normal)
	
  :general (leader-key
    "!"  (general-simulate-key "C-u C-c !" :which-key "Flycheck")))
(global-flycheck-mode 1)



(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package projectile
  :init
	(setq projectile-project-search-path '("~/git/"
																					"~/git/temp/"
																					"~/git/appkom/"
																					"~/git/pvv/"))
  (setq projectile-switch-project-action #'projectile-dired)

  :custom ((projectile-completion-system 'ivy))
  :bind-keymap ("C-c p" . projectile-command-map)
  :config (projectile-mode)

  :general (leader-key
        ;; File path
        "fR" 'projectile-recentf
        "fa" 'projectile-ag
        ;; "fyC" 'spacemacs/projectile-copy-file-path-with-line-column
        ;; "fyD" 'spacemacs/projectile-copy-directory-path
        ;; "fyL" 'spacemacs/projectile-copy-file-path-with-line
        ;; "fyY" 'spacemacs/projectile-copy-file-path
        ;; Project
        "p"  '(:ignore t :which-key "projectile")
        "p!" 'projectile-run-shell-command-in-root
        "p&" 'projectile-run-async-shell-command-in-root
        "p%" 'projectile-replace-regexp
        "pa" 'projectile-toggle-between-implementation-and-test
        "pb" 'projectile-switch-to-buffer
        "pc" 'projectile-compile-project
        "pd" 'projectile-find-dir
        "pD" 'projectile-dired
        "pe" 'projectile-edit-dir-locals
        "pf" 'projectile-find-file
        "pF" 'projectile-find-file-dwim
        "pg" 'projectile-find-tag
        "pG" 'projectile-regenerate-tags
        "pI" 'projectile-invalidate-cache
        "pk" 'projectile-kill-buffers
        "pp" 'projectile-switch-project
        "pr" 'projectile-recentf
        "pR" 'projectile-replace
        "pT" 'projectile-test-project
        "pv" 'projectile-vc))

(use-package swiper
  :general (leader-key
	  "s" '(swiper :which-key "search")))

(use-package yasnippet
  :init (yas-global-mode t)
  :config (yas-reload-all)
  :general (leader-key
    "y"  '(:ignore t :which-key "yasnippet")
    "yn" '(yas-new-snippet :which-key "New snippet")
    ;; "yi" '(yas-insert-snippet :which-key "Insert snippet")
    "y/" '(yas-visit-snippet-file :which-key "Find global snippet")
    "yr" '(yas-reload-all :which-key "Reload snippets")
    "yv" '(yas-describe-tables :which-key "View loaded snippets")))

(use-package ivy-yasnippet
  :after yasnippet
  :general (leader-key
    "yi" '(ivy-yasnippet :which-key "Insert snippet")))

(defvar company-mode/enable-yas t
  "Enable yasnippet for all backends.")

(defun company-mode/backend-with-yas (backend)
  (if (or (not company-mode/enable-yas) (and (listp backend) (member 'company-yasnippet backend)))
      backend
    (append (if (consp backend) backend (list backend))
            '(:with company-yasnippet))))

(setq company-backends (mapcar #'company-mode/backend-with-yas company-backends))

(use-package hl-todo
       :ensure t
       :custom-face
       (hl-todo ((t (:inherit hl-todo :italic t))))
       :hook ((prog-mode . hl-todo-mode)
              (yaml-mode . hl-todo-mode)))

(use-package magit
  :general (leader-key
    "g"  '(:ignore t            :which-key "git")
    "g/" '(magit-dispatch       :which-key "Magit dispatch")
    "g." '(magit-file-dispatch  :which-key "Magit file dispatch")
    ;; "g'" '(forge-dispatch       :which-key "Forge dispatch")
    "gg" '(magit-status         :which-key "Magit status")
    "gG" '(magit-status-here    :which-key "Magit status here")
    "gx" '(magit-file-delete    :which-key "Magit file delete")
    "gB" '(magit-blame-addition :which-key "Magit blame")
    "gC" '(magit-clone          :which-key "Magit clone")
    "gF" '(magit-fetch          :which-key "Magit fetch")
    "gL" '(magit-log            :which-key "Magit buffer log")
    "gS" '(magit-stage-file     :which-key "Git stage file")
    "gU" '(magit-unstage-file   :which-key "Git unstage file")

    "gf" '(:ignore t                   :which-key "find")
    "gff" '(magit-find-file            :which-key "Find file")
    "gfg" '(magit-find-git-config-file :which-key "Find gitconfig file")
    "gfc" '(magit-show-commit          :which-key "Find commit")


    "gl" '(:ignore t                 :which-key "list")
    ;; "glg" '(gist-list                :which-key "List gists")
    "glr" '(magit-list-repositories  :which-key "List repositories")
    "gls" '(magit-list-submodules    :which-key "List submodules")
    ;; "gli" '(forge-list-issues        :which-key "List issues")
    ;; "glp" '(forge-list-pullreqs      :which-key "List pull requests")
    ;; "gln" '(forge-list-notifications :which-key "List notifications")

    "gc" '(:ignore t             :which-key "create")
    "gcr" '(magit-init           :which-key "Initialize repo")
    "gcR" '(magit-clone          :which-key "Clone repo")
    "gcc" '(magit-commit-create  :which-key "Commit")
    "gcf" '(magit-commit-fixup   :which-key "Fixup")))
    ;; "gci" '(forge-create-issue   :which-key "Issue")
    ;; "gcp" '(forge-create-pullreq :which-key "Pull request")))

(use-package git-gutter
  :init
  (global-git-gutter-mode 1))

(use-package dart-mode
	:mode "\\.dart\\'")

(use-package lsp-dart
  :hook 'dart-mode-hook)

(use-package elm-mode
  :mode ("\\.elm\\'" . elm-mode)
  :after (company)
  :config (add-to-list 'company-backends 'elm-company)
  
  :general (leader-key elm-mode-map
  
    "mc"  '(:ignore t :which-key "compile")
    "mcb" 'elm-compile-buffer
    "mcm" 'elm-compile-main
    "mct" 'elm-test-project
    "mcr" 'elm-reactor
    "mcb" 'elm-preview-buffer
    "mcp" 'elm-preview-main
     
    "mh"  '(:ignore t :which-key "docs")
    "mhd" 'elm-documentation-lookup
    "mhh" 'elm-oracle-doc-at-point
    "mht" 'elm-oracle-type-at-point
    
    "m."  'elm-repl-load
    "mp"  'elm-repl-push
    "md"  'elm-repl-push-decl
    
    "mi"  'elm-import
    "me"  'elm-expose-at-point
    "ms"  'elm-sort-imports
    "mf"  'elm-format-buffer
    "mv"  'elm-package-catalog))

(use-package flycheck-elm
  :after (flycheck elm-mode)
  :hook (elm-mode-hook . flycheck-elm-setup))

(add-hook 'elm-mode-hook 'lsp)

(use-package highlight-defined
  :config
  (add-hook 'emacs-lisp-mode-hook 'highlight-defined-mode))

(use-package haskell-mode
  :general (leader-key haskell-mode-map

  "mh"  '(haskell-hide-toggle :which-key "hide")
  "mH"  '(haskell-hide-toggle-all :which-key "hide all")

  "mc"  '(:ignore t :which-key "cabal")
  "mcf" '(haskell-cabal-visit-file :which-key "cabal file")
  "mcb" '(haskell-process-cabal-build :which-key "build")))

(use-package hlint-refactor
  :hook (haskell-mode-hook . hlint-refactor-mode)
  :general (leader-key haskell-mode-map
    "mr" '(hlint-refactor-refactor-buffer :which-key "refactor suggestion")))

(use-package hindent
  :hook (haskell-mode-hook . hindent-mode))

(use-package lsp-haskell
  :hook (haskell-mode-hook . lsp)
        (haskell-literate-mode-hook . lsp))

(use-package lsp-java
  :init 
  ; (setq lsp-java-server-install-dir "/usr/share/java/jdtls/")
  (setenv "JAVA_HOME" "/usr/lib/jvm/default")
  (setq
	  lsp-java-java-path (substitute-in-file-name "$JAVA_HOME/bin/java")
		lsp-java-jdt-download-url "https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz")
  ; :hook (java-mode-hook . lsp)
  :config 
  (add-hook 'java-mode-hook 'flycheck-mode)
  (add-hook 'java-mode-hook 'company-mode)
  (add-hook 'java-mode-hook 'lsp)
	:general (leader-key java-mode-map
		;; LSP Java commands
		"mi" '(lsp-java-organize-imports :which-key "Organize imports")
		"mc" '(lsp-java-build-project    :which-key "Perform partial or full build for the projects")
		;; lsp-java-update-project-configuration - Update project configuration
		;; lsp-java-actionable-notifications - Resolve actionable notifications
		;; lsp-java-update-user-settings - Update user settings (Check the options in the table bellow.)
		;; lsp-java-update-server - Update server instalation.
		"mg"  '(:ignore t :which-key "Generate")
		"mgs" '(lsp-java-generate-to-string            :which-key "Generate toString method")
		"mge" '(lsp-java-generate-equals-and-hash-code :which-key "Generate equals and hashCode methods")
		"mgo" '(lsp-java-generate-overrides            :which-key "Generate method overrides")
		"mgg" '(lsp-java-generate-getters-and-setters  :which-key "Generate getters and setters")
		;; Refactoring
		;; LSP Java provides rich set of refactorings via Eclipse JDT Language Server code actions and some of them are bound to Emacs commands:

		"mr" '(:ignore t :which-key "Refactor")
		"mr" '(lsp-java-extract-to-constant       :which-key "Extract constant refactoring")
		"mr" '(lsp-java-add-unimplemented-methods :which-key "Extract constant refactoring")
		"mr" '(lsp-java-create-parameter          :which-key "Create parameter refactoring")
		"mr" '(lsp-java-create-field              :which-key "Create field refactoring")
		"mr" '(lsp-java-create-local              :which-key "Create local refactoring")
		"mr" '(lsp-java-extract-method            :which-key "Extract method refactoring")
		"mr" '(lsp-java-add-import                :which-key "Add missing import")

		;; Testing support
		"mt"  '(:ignore t :which-key "JUnit")
		"mtr" '(lsp-jt-report-open :which-key "open test report")
		"mtb" '(lsp-jt-browser :which-key "Browse tests and run/debug them.") 
    ;; ^^^ ** Use x to run the test(s) under point; d to debug the tests under point. R to refresh. ** Support for GUI operations.
		"mtl" '(lsp-jt-lens-mode :which-key "test lenses mode")

		;; Dependency viewer
		"md"  '(lsp-java-dependency-list :which-key "View java dependencies")))

(use-package maven-test-mode
  :hook (java-mode-hook . maven-test-mode)
    ;; (spacemacs/declare-prefix-for-mode 'java-mode "mm" "maven")
    ;; (spacemacs/declare-prefix-for-mode 'java-mode "mmg" "goto")
    ;; (spacemacs/declare-prefix-for-mode 'java-mode "mmt" "tests"))
  ;; :config
  ;; (progn
    ;; (spacemacs|hide-lighter maven-test-mode)
    ;; (spacemacs/set-leader-keys-for-minor-mode 'maven-test-mode
  :general (leader-key maven-test-mode-map
		  "mm"      '(:ignore t :which-key "Maven")
      "mmga"    'maven-test-toggle-between-test-and-class
      "mmgA"    'maven-test-toggle-between-test-and-class-other-window
      "mmta"    'maven-test-all
      "mmt C-a" 'maven-test-clean-test-all
      "mmtb"    'maven-test-file
      "mmti"    'maven-test-install
      "mmtt"    'maven-test-method))



(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp)
  :config
  (setq typescript-indent-level 2))

(use-package json-mode
  :mode "\\.js\\(?:on\\|[hl]int\\(?:rc\\)?\\)\\'"
  :hook (json-mode . lsp)
  ; :config
  ; (set-electric! 'json-mode :chars '(?\n ?: ?{ ?}))
  :general (leader-key json-mode-map
    "mp" '(json-mode-show-path :which-key "Copy path")
    "mt" 'json-toggle-boolean
    "md" 'json-mode-kill-path
    "mx" 'json-nullify-sexp
    "m+" 'json-increment-number-at-point
    "m-" 'json-decrement-number-at-point
    "mf" 'json-mode-beautify))

(use-package tex
  ;; :after (pdf-tools)
  :ensure auctex
  :mode ("\\.tex\\'" . LaTeX-mode)
  :config
	  (setq
		  TeX-source-correlate-method 'synctex
			TeX-source-correlate-start-server t
      TeX-auto-save t
	    TeX-parse-self t
	  ; reftex-plug-into-AUCTeX t
      TeX-PDF-mode t)                       ; Use PDF instead of DVI

	  (setq-default
		  TeX-master "main.tex"
			TeX-engine 'default)                 ; default | xetex | luatex

	  (TeX-source-correlate-mode t)               ; 

	  (add-hook 'LaTeX-mode-hook
		  (lambda ()
			  (reftex-mode t)
				(flyspell-mode t)))
				
	:general (leader-key
    "mc" '(TeX-command-run-all :which-key "Compile")
    "me" '(TeX-engine-set :which-key "Set engine")
    "mv" '(TeX-view :which-key "view")))

(use-package company-auctex
  :after auctex
	:hook LaTeX-mode
	:config
    (company-auctex-init)
    (add-to-list 'company-backends 'company-yasnippet)
		(company-mode))
	
	;; :config
  ;;   (add-to-list '+latex--company-backends #'company-auctex-environments nil #'eq)
  ;;   (add-to-list '+latex--company-backends #'company-auctex-macros nil #'eq))

(use-package auctex-latexmk
  :after auctex
  (auctex-latexmk-setup)
  (setq auctex-latexmk-inherit-TeX-PDF-mode t))

(use-package pdf-tools
  ;; :hook

  ;; (add-hook 'pdf-view-mode-hook (lambda ()
	;; 			  (bms/pdf-midnite-amber))) ; automatically turns on midnight-mode for pdfs
	:init
  ;;   (pdf-tools-install)
    (setq
      TeX-view-program-selection '((output-pdf "pdf-tools"))
      TeX-view-program-list '(("pdf-tools" "TeX-pdf-tools-sync-view")))

  :config
    (setq-default pdf-view-display-size 'fit-page)
    (setq pdf-annot-activate-created-annotations t)

    (add-hook 'TeX-after-compilation-finished-functions ;; Update PDF buffers after successful LaTeX runs
               #'TeX-revert-document-buffer)	

	:general (leader-key pdf-view-mode-map
    "mf" 'isearch-forward
    "mb" 'isearch-backward))

(use-package cdlatex
  :general (leader-key
	"mis" 'cdlatex-sub-superscript
	"mip" 'cdlatex-lr-pair
	"mie" 'cdlatex-environment))

;; (use-package math-preview)
;; (use-package preview-latex)

; (use-package latex-preview-pane)

; (use-package lsp-latex)

(leader-key LaTeX-mode-map
  "mm"    '(:ignore t                 :which-key "Insert math")
	"mm^"   '(LaTeX-math-wedge          :which-key "∧")
	"mmv"   '(LaTeX-math-vee            :which-key "∨")
	"mm=>"  '(LaTeX-math-Rightarrow     :which-key "=>")
	"mm->"  '(LaTeX-math-rightarrow     :which-key "->")
	"mm<==" '(LaTeX-math-Leftarrow      :which-key "<=")
	"mm<-"  '(LaTeX-math-leftarrow      :which-key "<-")
	"mm<=>" '(LaTeX-math-Leftrightarrow :which-key "<=>")
	"mm=="  '(LaTeX-math-equiv          :which-key "≡")
	"mm!="  '(LaTeX-math-neq            :which-key "≠")
	"mmn"   '(LaTeX-math-neg            :which-key "¬")
	"mma"   '(LaTeX-math-forall         :which-key "∀")
	"mme"   '(LaTeX-math-exists         :which-key "∃")
	"mmt"   '(LaTeX-math-top            :which-key "⊤")
	"mmT"   '(LaTeX-math-bot            :which-key "⊥")
	"mm."   '(LaTeX-math-therefore      :which-key "∴")
	"mm,"   '(LaTeX-math-because        :which-key "∵"))

(defun ntnu/expand-truth-table ()
  (interactive)
  (save-excursion
    (let
		  (start
			 end
			 (l/rep (lambda (pat repl)
			   (setq
			     start (evil-range-beginning (evil-visual-range))
           end (evil-range-end (evil-visual-range)))
         (replace-regexp pat repl nil start end))))
			;; (evil-ex-substitute start end '("[tT]") "\\\\T" '("g")))))
			(funcall l/rep "[tT]" "\\\\T")
			(funcall l/rep "[fF]" "\\\\F")
			(funcall l/rep " " " & ")
			(funcall l/rep "$" " \\\\\\\\"))))

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init 
  (setq markdown-enable-math t ; syntax highlighting for latex fragments
        markdown-enable-wiki-links t
        markdown-italic-underscore t
        markdown-asymmetric-header t
        markdown-fontify-code-blocks-natively t
        markdown-gfm-additional-languages '("sh")
        markdown-make-gfm-checkboxes-buttons t
        markdown-content-type "application/xhtml+xml"
        markdown-css-paths
        ; markdown-command "multimarkdown"
        '("https://cdn.jsdelivr.net/npm/github-markdown-css/github-markdown.min.css"
          "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release/build/styles/github.min.css")
        markdown-xhtml-header-content
        (concat "<meta name='viewport' content='width=device-width, initial-scale=1, shrink-to-fit=no'>"
                "<style> body { box-sizing: border-box; max-width: 740px; width: 100%; margin: 40px auto; padding: 0 10px; } </style>"
                "<script id='MathJax-script' async src='https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js'></script>"
                "<script src='https://cdn.jsdelivr.net/gh/highlightjs/cdn-release/build/highlight.min.js'></script>"
                "<script>document.addEventListener('DOMContentLoaded', () => { document.body.classList.add('markdown-body'); document.querySelectorAll('pre[lang] > code').forEach((code) => { code.classList.add(code.parentElement.lang); }); document.querySelectorAll('pre > code').forEach((code) => { hljs.highlightBlock(code); }); });</script>"))
  :general (leader-key markdown-mode-map
        "m'" 'markdown-edit-code-block
        "mo" 'markdown-open
        "mp" 'markdown-preview
        "me" 'markdown-export
        ; "mp" 'grip-mode)

        "mi" '(:ignore t :which-key "insert")
        ; "mit" 'markdown-toc-generate-toc
        "mii" 'markdown-insert-image
        "mil" 'markdown-insert-link))

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package python-mode)

(setq lsp-pyls-plugins-autopep8-enabled nil)
(setq lsp-pyls-plugins-yapf-enabled t)
(add-hook 'python-mode-hook 'lsp)

(defun prettify-python ()
  (set-face-attribute font-lock-keyword-face nil :font "CMU Serif" :slant 'italic :height 160)
  (setq prettify-symbols-alist '(
    ("def"    . "f")
    ("lambda" . "λ")
    ("delta"  . "Δ")
    ("for"    . "∀")
    ("not in" . "∉")
    ("in"     . "∈")
    ("return" . "→")
    ("->" . "→")
    ("\\n" . "⏎")
    ("!=" . "≠")
    ("not"    . "¬")
    ("and"    . "^")
    ("or"     . "∨")
    ("pi"     . "π"))))

;; (add-hook 'python-mode-hook 'prettify-symbols-mode)
;; (add-hook 'python-mode-hook 'prettify-python)

(use-package rustic
  :bind (:map rustic-mode-map
              ("M-j" . lsp-ui-imenu)
              ("M-?" . lsp-find-references)
              ("C-c C-c l" . flycheck-list-errors)
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown)
              ("C-c C-c s" . lsp-rust-analyzer-status))
  :config
  ;; uncomment for less flashiness
  ;; (setq lsp-eldoc-hook nil)
  ;; (setq lsp-enable-symbol-highlighting nil)
  ;; (setq lsp-signature-auto-activate nil)

  ;; comment to disable rustfmt on save
  (setq rustic-format-on-save t)
  (add-hook 'rustic-mode-hook 'rk/rustic-mode-hook))

(defun rk/rustic-mode-hook ()
  ;; so that run C-c C-c C-r works without having to confirm, but don't try to
  ;; save rust buffers that are not file visiting. Once
  ;; https://github.com/brotzeit/rustic/issues/253 has been resolved this should
  ;; no longer be necessary.
  (when buffer-file-name
    (setq-local buffer-save-without-query t)))

(use-package emmet-mode
  :hook (sgml-mode-hook . emmet-mode)
				(html-mode-hook . emmet-mode)
				(css-mode-hook  . emmet-mode))

(use-package drag-stuff
  :bind (("M-j" . drag-stuff-down)
         ("M-k" . drag-stuff-up)
         ;; ("M-h" . drag-left-stuff)
         ;; ("M-l" . drag-stuff-right)
         ))

(use-package emojify
  :hook (after-init-hook . global-emojify-mode)
  :general (leader-key
    "ie" 'emojify-insert-emoji))

(use-package lorem-ipsum
 :general (leader-key
  "il"  '(:ignore t :which-key "lorem ipsum")
  "ill" 'lorem-ipsum-insert-list
  "ils" 'lorem-ipsum-insert-sentences
  "ilp" 'lorem-ipsum-insert-paragraphs))

;; (use-package multiple-cursors
;;   :general (leader-key
;;     "d"          '(:ignore t                      :which-key "multiple cursors")
;;     "dl"         '(mc/edit-lines                  :which-key "edit lines")
;;     "dn"         '(mc/mark-next-like-this         :which-key "mark next")
;;     "dN"         '(mc/unmark-next-like-this       :which-key "unmark next")
;;     "dp"         '(mc/mark-previous-like-this     :which-key "mark previous")
;;     "dP"         '(mc/unmark-previous-like-this   :which-key "unmark previous")
;;     "dt"         '(mc/mark-all-like-this          :which-key "mark all")
;;     "dm"         '(mc/mark-all-like-this-dwim     :which-key "mark all DWIM")
;;     "de"         '(mc/edit-ends-of-lines          :which-key "edit line endings")
;;     "da"         '(mc/edit-beginnings-of-lines    :which-key "edit line starts")
;;     "ds"         '(mc/mark-sgml-tag-pair          :which-key "mark tag")
;;     "dd"         '(mc/mark-all-like-this-in-defun :which-key "mark in defun")))
    ;; "w<mouse-1>" '(mc/add-cursor-on-click         :which-key "add cursor w/mouse")))

(use-package recentf
  :init (recentf-mode t)
  :config
  (add-to-list 'recentf-exclude (format "%s/\\.emacs\\.d/elpa/.*" (getenv "HOME")))
  (add-to-list 'recentf-exclude "~/\\.emacs\\.d/elpa/.*")
  :general (leader-key
   "fr" 'counsel-recentf))

(use-package treemacs
  
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") 'treemacs-select-window))
    
  :config
  (progn
    (setq treemacs-collapse-dirs              (if (executable-find "python") 3 0)
          treemacs-deferred-git-apply-delay   0.5
          treemacs-display-in-side-window     t
          treemacs-file-event-delay           5000
          treemacs-file-follow-delay          0.2
          treemacs-follow-after-init          t
          treemacs-follow-recenter-distance   0.1
          treemacs-git-command-pipe           ""
          treemacs-goto-tag-strategy          'refetch-index
          treemacs-indentation                2
          treemacs-indentation-string         " "
          treemacs-is-never-other-window      nil
          treemacs-max-git-entries            5000
          treemacs-no-png-images              nil
          treemacs-no-delete-other-windows    t
          treemacs-project-follow-cleanup     nil
          treemacs-persist-file               (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-recenter-after-file-follow nil
          treemacs-recenter-after-tag-follow  nil
          treemacs-show-cursor                nil
          treemacs-show-hidden-files          nil
          treemacs-silent-filewatch           nil
          treemacs-silent-refresh             nil
          treemacs-sorting                    'alphabetic-desc
          treemacs-space-between-root-nodes   t
          treemacs-tag-follow-cleanup         t
          treemacs-tag-follow-delay           1.5
          treemacs-width                      35)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode t)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null (executable-find "python3"))))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
       
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))
        
  :general (leader-key
    "t"   '(:ignore t :which-key "treemacs")
    "tt"  'treemacs)

(use-package treemacs-evil
  :after (treemacs evil))

(use-package treemacs-projectile
  :after (treemacs projectile))

(use-package lsp-treemacs
  :after (treemacs lsp)
  :config (lsp-treemacs-sync-mode 1))

(use-package treemacs-magit
  :after (treemacs magit))

(use-package treemacs-icons-dired
  :after treemacs)

(use-package which-key
  :config 
    (setq which-key-idle-delay 0.3)
    (setq which-key-popup-type 'frame)
    (which-key-mode)
    (which-key-setup-side-window-right-bottom)
    ; (which-key-setup-minibuffer)
    (set-face-attribute 'which-key-local-map-description-face nil 
       :weight 'bold))

(use-package writeroom-mode
  :config (setq fringes-outside-margins 1)
  :general (leader-key
  "z" '(writeroom-mode :which-key "zen")))

(setq default-input-method nil)
;; (map! :leader
;;       (:prefix-map ("l" . "language")
;;         :desc "English"   "e" (lambda () (interactive) (deactivate-input-method))
;;         :desc "Japanese"  "j" (lambda () (interactive) (set-input-method 'japanese))
;;         :desc "Norwegian" "n" (lambda () (interactive) (set-input-method 'norwegian-keyboard))
;;         :desc "Latin"     "l" (lambda () (interactive) (set-input-method 'latin-1-postfix))
;;         :desc "TeX"       "t" (lambda () (interactive) (set-input-method 'TeX))))

(defun header_comment ()
  "Function to make a header comment"
    (interactive)
    (save-excursion
      (let (start end commentString)
        (setq start (line-beginning-position) )
        (setq end   (line-end-position) )
        (setq commentString (thing-at-point 'line) )

        (delete-region start end)
        (insert
         (concat
          (cdr (call-process "toilet" nil t nil "-f" "pagga" commentString)) "\n"
           commentString))
        (comment-region start (line-end-position))
        )))

(leader-key
  "ic" '(header_comment :which-key "header comment"))

;; (use-package! flycheck-popup-tip
;;   :config (flycheck-popup-tip-error-prefix "E -> "))
;; 
;; (defun scroll-error-up ()
;;   (interactive)
;;   (message (prin1-to-string flycheck-popup-tip-object))
;;   (popup-scroll-up flycheck-popup-tip-object))
;; 
;; (defun scroll-error-down ()
;;   (interactive)
;;   (popup-scroll-down flycheck-popup-tip-object))


;; (map!
;;  (:after flycheck-popup-tip
;;    :en "C-j"   #'scroll-error-down
;;    :en "C-k"   #'scroll-error-up))
