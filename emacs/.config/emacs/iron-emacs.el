(add-to-list 'load-path "~/.config/emacs/scripts/")

(require 'elpaca-setup)  ;; The Elpaca Package Manager
(require 'buffer-move)   ;; Buffer-move for better window management
(require 'app-launchers) ;; Use emacs as a run launcher like dmenu (experimental)

(use-package all-the-icons
  :ensure t
  :if (display-graphic-p))

(use-package all-the-icons-dired
  :ensure t
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(setq backup-directory-alist '((".*" . "~/.Trash")))

(use-package company
  :ensure t
  :defer 2
  :diminish
  ;; go autocomplete
  :hook (go-mode . company-mode)
  :custom
  (company-begin-commands '(self-insert-command))
  (company-idle-delay .1)
  (company-minimum-prefix-length 2)
  (company-show-numbers t)
  (company-tooltip-align-annotations 't)
  (global-company-mode t))

(use-package company-box
  :after company
  :ensure t
  :diminish
  :hook (company-mode . company-box-mode))

(use-package dashboard
  :ensure t 
  :demand t
  :init
  (setq initial-buffer-choice 'dashboard-open)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "Emacs Is More Than A Text Editor!")
  ;;(setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
  (setq dashboard-startup-banner "/home/derrick/.config/emacs/images/emacs-dash.png")  ;; use custom image as banner
  (setq dashboard-center-content nil) ;; set to 't' for centered content
  (setq dashboard-items '((recents . 5)
                          (agenda . 5 )
                          (bookmarks . 3)
                          (projects . 3)
                          (registers . 3)))
  :custom
  (dashboard-modify-heading-icons '((recents . "file-text")
                                    (bookmarks . "book")))
  :config
  (dashboard-setup-startup-hook))

(use-package diminish :ensure t)

(use-package dired-open
  :ensure t
  :config
  (setq dired-open-extensions '(("gif" . "sxiv")
                                ("jpg" . "sxiv")
                                ("png" . "sxiv")
                                ("mkv" . "mpv")
                                ("mp4" . "mpv"))))

(use-package peep-dired
  :after dired
  :ensure t
  :hook (evil-normalize-keymaps . peep-dired-hook)
  :config
    (evil-define-key 'normal dired-mode-map (kbd "h") 'dired-up-directory)
    (evil-define-key 'normal dired-mode-map (kbd "l") 'dired-open-file) ; use dired-find-file instead if not using dired-open package
    (evil-define-key 'normal peep-dired-mode-map (kbd "j") 'peep-dired-next-file)
    (evil-define-key 'normal peep-dired-mode-map (kbd "k") 'peep-dired-prev-file)
)

;;(add-hook 'peep-dired-hook 'evil-normalize-keymaps)

(use-package elfeed
  :ensure t
  :config
  (setq elfeed-search-feed-face ":foreground #ffffff :weight bold"
        elfeed-feeds (quote
                       (("https://www.reddit.com/r/linux.rss" reddit linux)
                        ("https://www.reddit.com/r/commandline.rss" reddit commandline)
                        ("https://www.reddit.com/r/distrotube.rss" reddit distrotube)
                        ("https://www.reddit.com/r/emacs.rss" reddit emacs)
                        ("https://www.gamingonlinux.com/article_rss.php" gaming linux)
                        ("https://hackaday.com/blog/feed/" hackaday linux)
                        ("https://opensource.com/feed" opensource linux)
                        ("https://linux.softpedia.com/backend.xml" softpedia linux)
                        ("https://itsfoss.com/feed/" itsfoss linux)
                        ("https://www.zdnet.com/topic/linux/rss.xml" zdnet linux)
                        ("https://www.phoronix.com/rss.php" phoronix linux)
                        ("http://feeds.feedburner.com/d0od" omgubuntu linux)
                        ("https://www.computerworld.com/index.rss" computerworld linux)
                        ("https://www.networkworld.com/category/linux/index.rss" networkworld linux)
                        ("https://www.techrepublic.com/rssfeeds/topic/open-source/" techrepublic linux)
                        ("https://betanews.com/feed" betanews linux)
                        ("http://lxer.com/module/newswire/headlines.rss" lxer linux)
                        ("https://distrowatch.com/news/dwd.xml" distrowatch linux)))))
 
(use-package elfeed-goodies
  :ensure t
  :demand t
  :init
  (elfeed-goodies/setup)
  :config
  (setq elfeed-goodies/entry-pane-size 0.5))

(use-package evil
    :ensure t
    :demand t
    :init      ;; tweak evil's configuration before loading it
    (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
    (setq evil-want-keybinding nil)
    (setq evil-vsplit-window-right t)
    (setq evil-split-window-below t)
    (evil-mode))
  (use-package evil-collection
    :after evil
    :ensure t
    :config
    (setq evil-collection-mode-list '(dashboard dired ibuffer))
    (evil-collection-init))
  (use-package evil-tutor :ensure t)

(use-package flycheck
  :ensure t
  :demand t
  :defer t
  :diminish
  ;; go syntax checking
  :hook (go-mode . flycheck-mode)
  :init (global-flycheck-mode))

(set-face-attribute 'default nil
  :font "JetBrains Mono"
  :height 110
  :weight 'medium)
(set-face-attribute 'variable-pitch nil
  :font "Ubuntu"
  :height 120
  :weight 'medium)
(set-face-attribute 'fixed-pitch nil
  :font "JetBrains Mono"
  :height 110
  :weight 'medium)
;; Makes commented text and keywords italics.
;; This is working in emacsclient but not emacs.
;; Your font must have an italic face available.
(set-face-attribute 'font-lock-comment-face nil
  :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
  :slant 'italic)

;; This sets the default font on all graphical frames created after restarting Emacs.
;; Does the same thing as 'set-face-attribute default' above, but emacsclient fonts
;; are not right unless I also add this method of setting the default font.
(add-to-list 'default-frame-alist '(font . "JetBrains Mono-11"))

;; Uncomment the following line if line spacing needs adjusting.
(setq-default line-spacing 0.12)

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(use-package general
  :ensure t
  :config
  (general-evil-setup)

  ;; set up 'SPC' as the global leader key
  (general-create-definer iron/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC") ;; access leader in insert mode
  
  (iron/leader-keys
    "SPC" '(counsel-M-x :wk "Counsel M-x")
    "." '(find-file :wk "Find file")
    "=" '(perspective-map :wk "Perspective") ;; Lists all the perspective keybindings
    "TAB TAB" '(comment-line :wk "Comment lines")
    "u" '(universal-argument :wk "Universal argument"))

  (iron/leader-keys
    "b" '(:ignore t :wk "[B]uffer")
    "b c" '(clone-indirect-buffer :wk "Create indirect buffer [C]opy in a split")
    "b C" '(clone-indirect-buffer-other-window :wk "[C]lone indirect buffer in new window")
    "b d" '(bookmark-delete :wk "Delete bookmark")
    "b i" '(ibuffer :wk "[I]buffer")
    "b k" '(kill-this-buffer :wk "[K]ill this buffer")
    "b K" '(kill-some-buffers :wk "[K]ill multiple buffers")
    "b l" '(list-bookmarks :wk "[L]ist bookmarks")
    "b m" '(bookmark-set :wk "Set book[M]ark")
    "b n" '(next-buffer :wk "[N]ext buffer")
    "b p" '(previous-buffer :wk "[P]revious buffer")
    "b r" '(revert-buffer :wk "[R]eload buffer")
    "b R" '(rename-buffer :wk "[R]ename buffer")
    "b s" '(basic-save-buffer :wk "[S]ave buffer")
    "b S" '(save-some-buffers :wk "[S]ave multiple buffers")
    "b w" '(bookmark-save :wk "[W]rite/Save current bookmarks to bookmark file"))
  
  (iron/leader-keys
    "d" '(:ignore t :wk "[D]ired")
    "d d" '(dired :wk "Open [D]ired")
    "d j" '(dired-jump :wk "Dired [J]ump to current")
    "d n" '(neotree-dir :wk "Open directory in [N]eotree")
    "d p" '(peep-dired :wk "Peep-dired"))
  
  (iron/leader-keys
    "e" '(:ignore t :wk "[E]shell/[E]valuate")    
    "e b" '(eval-buffer :wk "Evaluate elisp in [B]uffer")
    "e d" '(eval-defun :wk "Evaluate [D]efun containing or after point")
    "e e" '(eval-expression :wk "Evaluate and elisp [E]xpression")
    "e h" '(counsel-esh-history :wk "Eshell [H]istory")
    "e l" '(eval-last-sexp :wk "Evaluate [L]ast elisp expression before point")
    "e r" '(eval-region :wk "Evaluate elisp in [R]egion")
    "e R" '(eww-reload :which-key "[R]eload current page in EWW")
    "e s" '(eshell :wk "E[S]hell")
    "e w" '(eww :wk "EWW emacs [W]eb browser"))

  (iron/leader-keys
    "f" '(:ignore t :wk "[F]iles")
    "f c" '((lambda () (interactive) 
	      (find-file "~/.config/emacs/iron-emacs.org")) 
	    :wk "[F]ind emacs [C]onfig")
    "f e" '((lambda () (interactive)
	      (dired "~/.config/emacs/"))
	    :wk "Open user-[E]macs-directory in dired")
    "f d" '(find-grep-dired :wk "Search for string in files in [D]IR")
    "f g" '(counsel-grep-or-swiper :wk "[G]rep for string in current file")
    "f i" '((lambda () (interactive)
	      (find-file "~/.config/emacs/init.el"))
	    :wk "Open emacs [I]nit.el")
    "f j" '(counsel-file-jump :wk "[J]ump to a file below current directory")
    "f l" '(counsel-locate :wk "[L]ocate a file")
    "f r" '(counsel-recentf :wk "Find [R]ecent files")
    "f u" '(sudo-edit-find-file :wk "S[U]do find file")
    "f U" '(sudo-edit :wk "S[U]do edit file"))
  
  (iron/leader-keys
    "g" '(:ignore t :wk "[G]it")    
    "g /" '(magit-displatch :wk "Magit dispatch [/]")
    "g ." '(magit-file-displatch :wk "Magit file dispatch [.]")
    "g b" '(magit-branch-checkout :wk "Switch [B]ranch")
    "g c" '(:ignore t :wk "[C]reate") 
    "g c b" '(magit-branch-and-checkout :wk "Create [B]ranch and checkout")
    "g c c" '(magit-commit-create :wk "Create [C]ommit")
    "g c f" '(magit-commit-fixup :wk "Create [F]ixup commit")
    "g C" '(magit-clone :wk "[C]lone repo")
    "g f" '(:ignore t :wk "[F]ind") 
    "g f c" '(magit-show-commit :wk "Show [C]ommit")
    "g f f" '(magit-find-file :wk "Magit find [F]ile")
    "g f g" '(magit-find-git-config-file :wk "Find [G]itconfig file")
    "g F" '(magit-fetch :wk "Git [F]etch")
    "g g" '(magit-status :wk "Ma[G]it status")
    "g i" '(magit-init :wk "[I]nitialize git repo")
    "g l" '(magit-log-buffer-file :wk "Magit buffer [L]og")
    "g r" '(vc-revert :wk "Git [R]evert file")
    "g s" '(magit-stage-file :wk "Git [S]tage file")
    "g t" '(git-timemachine :wk "Git [T]ime machine")
    "g u" '(magit-stage-file :wk "Git [U]nstage file"))

  (iron/leader-keys
    "h" '(:ignore t :wk "[H]elp")  
    "h a" '(counsel-apropos :wk "[A]propos")
    "h b" '(describe-bindings :wk "Describe [B]indings")
    "h c" '(describe-char :wk "Describe [C]haracter under cursor")
    "h d" '(:ignore t :wk "Emacs [D]ocumentation")
    "h d a" '(about-emacs :wk "[A]bout Emacs")
    "h d d" '(view-emacs-debugging :wk "View Emacs [D]ebugging")
    "h d f" '(view-emacs-FAQ :wk "View Emacs [F]AQ")
    "h d m" '(info-emacs-manual :wk "The Emacs [M]anual") 
    "h d n" '(view-emacs-news :wk "View Emacs [N]ews")
    "h d o" '(describe-distribution :wk "How to [O]btain Emacs")
    "h d p" '(view-emacs-problems :wk "View Emacs [P]roblems")
    "h d t" '(view-emacs-todo :wk "View Emacs [T]odo")
    "h d w" '(describe-no-warranty :wk "Describe no [W]arranty")
    "h e" '(view-echo-area-messages :wk "View [E]cho area messages")
    "h f" '(describe-function :wk "Describe [F]unction")
    "h F" '(describe-face :wk "Describe [F]ace")
    "h g" '(describe-gnu-project :wk "Describe [G]NU Project")
    "h i" '(info :wk "[I]nfo")
    "h I" '(describe-input-method :wk "Describe [I]nput method")
    "h k" '(describe-key :wk "Describe [K]ey")
    "h l" '(view-lossage :wk "Display recent keystrokes and the commands run")
    "h L" '(describe-language-environment :wk "Describe [L]anguage environment")
    "h m" '(describe-mode :wk "Describe [M]ode")
    "h r" '(:ignore t :wk "[R]eload")
    "h r r" '((lambda () (interactive)
		(load-file "~/.config/emacs/init.el")
		(ignore (elpaca-process-queues)))
              :wk "Reload emacs config")
    "h t" '(load-theme :wk "Load [T]heme")
    "h v" '(describe-variable :wk "Describe [V]ariable")
    "h w" '(where-is :wk "Prints keybinding for command if set")
    "h x" '(describe-command :wk "Display full documentation for command"))
 
 (iron/leader-keys
    "m" '(:ignore t :wk "Org")
    "m a" '(org-agenda :wk "Org [A]genda")
    "m e" '(org-export-dispatch :wk "Org [E]xport dispatch")
    "m i" '(org-toggle-item :wk "Org toggle [I]tem")
    "m t" '(org-todo :wk "Org [T]odo")
    "m B" '(org-babel-tangle :wk "Org [B]abel tangle")
    "m T" '(org-todo-list :wk "Org [T]odo list"))

 (iron/leader-keys
    "m b" '(:ignore t :wk "Tables")
    "m b -" '(org-table-insert-hline :wk "Insert hline in table"))

 (iron/leader-keys
    "m d" '(:ignore t :wk "Date/deadline")
    "m d t" '(org-time-stamp :wk "Org time stamp"))

 (iron/leader-keys
    "o" '(:ignore t :wk "[O]pen")
    "o d" '(dashboard-open :wk "[D]ashboard")
    "o e" '(elfeed :wk "[E]lfeed RSS")
    "o f" '(make-frame :wk "Open buffer in new [F]rame")
    "o F" '(select-frame-by-name :wk "Select [F]rame by name"))

 (iron/leader-keys
    "p" '(projectile-command-map :wk "[P]rojectile"))

 (iron/leader-keys
    "s" '(:ignore t :wk "[S]earch")
    "s d" '(dictionary-search :wk "Search [D]ictionary")
    "s m" '(man :wk "[M]an pages")
    "s t" '(tldr :wk "Lookup [T]LDR docs for a command")
    "s w" '(woman :wk "[W]oman pages: similar to man but doesn't require man"))

 (iron/leader-keys
    "t" '(:ignore t :wk "[T]oggle")
    "t e" '(eshell-toggle :wk "Toggle [E]shell")
    "t f" '(flycheck-mode :wk "Toggle [F]lycheck")
    "t l" '(display-line-numbers-mode :wk "Toggle [L]ine numbers")
    "t n" '(neotree-toggle :wk "Toggle [N]eotree file viewer")
    "t o" '(org-mode :wk "Toggle [O]rg mode")
    "t r" '(rainbow-mode :wk "Toggle [R]ainbow mode")
    "t t" '(visual-line-mode :wk "Toggle [T]runcated lines")
    "t v" '(vterm-toggle :wk "Toggle [V]term"))

 (iron/leader-keys
    "w" '(:ignore t :wk "[W]indows")
    ;; Window splits
    "w c" '(evil-window-delete :wk "[C]lose window")
    "w n" '(evil-window-new :wk "[N]ew window")
    "w s" '(evil-window-split :wk "Horizontal [S]plit window")
    "w v" '(evil-window-vsplit :wk "[V]ertical split window")
    ;; Window motions
    "w h" '(evil-window-left :wk "Window left [H]")
    "w j" '(evil-window-down :wk "Window down [J]")
    "w k" '(evil-window-up :wk "Window up [K]")
    "w l" '(evil-window-right :wk "Window right [L]")
    "w w" '(evil-window-next :wk "Goto next [W]indow")
    ;; Move Windows
    "w H" '(buf-move-left :wk "Buffer move left [H]")
    "w J" '(buf-move-down :wk "Buffer move down [J]")
    "w K" '(buf-move-up :wk "Buffer move up [K]")
    "w L" '(buf-move-right :wk "Buffer move right [L]"))
)

(use-package git-timemachine
  :after git-timemachine
  :ensure t
  :hook (evil-normalize-keymaps . git-timemachine-hook)
  :config
    (evil-define-key 'normal git-timemachine-mode-map (kbd "C-j") 'git-timemachine-show-previous-revision)
    (evil-define-key 'normal git-timemachine-mode-map (kbd "C-k") 'git-timemachine-show-next-revision)
)

;; (use-package magit :ensure t)

(use-package hl-todo
  :ensure t
  :hook ((org-mode . hl-todo-mode)
         (prog-mode . hl-todo-mode))
  :config
  (setq hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        `(("TODO"       warning bold)
          ("FIXME"      error bold)
          ("HACK"       font-lock-constant-face bold)
          ("REVIEW"     font-lock-keyword-face bold)
          ("NOTE"       success bold)
          ("DEPRECATED" font-lock-doc-face bold))))

(use-package counsel
  :after ivy
  :ensure t
  :diminish
  :config (counsel-mode))

(use-package ivy
  :ensure t
  :bind
  ;; ivy-resume resumes the last Ivy-based completion.
  (("C-c C-r" . ivy-resume)
   ("C-x B" . ivy-switch-buffer-other-window))
  :diminish
  :custom
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)
  :config
  (ivy-mode))

(use-package all-the-icons-ivy-rich
  :ensure t
  :init (all-the-icons-ivy-rich-mode 1))

(use-package ivy-rich
  :after ivy
  :ensure t
  :demand t
  :init (ivy-rich-mode 1) ;; this gets us descriptions in M-x.
  :custom
  (ivy-virtual-abbreviate 'full
   ivy-rich-switch-buffer-align-virtual-buffer t
   ivy-rich-path-style 'abbrev)
  :config
  (ivy-set-display-transformer 'ivy-switch-buffer
                               'ivy-rich-switch-buffer-transformer))

(use-package haskell-mode :ensure t)
(use-package lua-mode :ensure t)

;; Configure lsp-mode
(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :config
  (setq lsp-prefer-flymake nil))

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

(use-package company-lsp
  :ensure t
  :commands company-lsp)

;; Install and configure go-mode
(use-package go-mode
  :ensure t
  :hook ((go-mode . lsp-deferred)
	 (before-save . gofmt-before-save))
  :config
  (setq tab-width 4)
  (setq indent-tabs-mode 1))

;; Function to run the current Go file
(defun my-go-run ()
  "Run the current Go file."
  (interactive)
  (let ((compile-command (concat "go run " buffer-file-name)))
    (compile compile-command)))

;; Function to build the current Go project
(defun my-go-build ()
  "Build the current Go project."
  (interactive)
  (compile "go build"))

;; Function to test the current Go project
(defun my-go-test ()
  "Test the current Go project."
  (interactive)
  (compile "go test ./..."))

;; Add key bindings for Go commands
(add-hook 'go-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c C-r") 'my-go-run)
            (local-set-key (kbd "C-c C-b") 'my-go-build)
            (local-set-key (kbd "C-c C-t") 'my-go-test)))

(global-set-key [escape] 'keyboard-escape-quit)

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 35      ;; sets modeline height
        doom-modeline-bar-width 5    ;; sets right bar width
        doom-modeline-persp-name t   ;; adds perspective name to modeline
        doom-modeline-persp-icon t)) ;; adds folder icon next to persp name

(use-package neotree
  :ensure t
  :config
  (setq neo-smart-open t
        neo-show-hidden-files t
        neo-window-width 55
        neo-window-fixed-size nil
        inhibit-compacting-font-caches t
        projectile-switch-project-action 'neotree-projectile-action) 
        ;; truncate long file names in neotree
        (add-hook 'neo-after-create-hook
           #'(lambda (_)
               (with-current-buffer (get-buffer neo-buffer-name)
                 (setq truncate-lines t)
                 (setq word-wrap nil)
                 (make-local-variable 'auto-hscroll-mode)
                 (setq auto-hscroll-mode nil)))))

;; show hidden files

(use-package toc-org
    :ensure t
    :demand t
    :commands toc-org-enable
    :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets :ensure t)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(eval-after-load 'org-indent '(diminish 'org-indent-mode))

(custom-set-faces
 '(org-level-1 ((t (:inherit outline-1 :height 1.7))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.6))))
 '(org-level-3 ((t (:inherit outline-3 :height 1.5))))
 '(org-level-4 ((t (:inherit outline-4 :height 1.4))))
 '(org-level-5 ((t (:inherit outline-5 :height 1.3))))
 '(org-level-6 ((t (:inherit outline-5 :height 1.2))))
 '(org-level-7 ((t (:inherit outline-5 :height 1.1)))))

(require 'org-tempo)

(use-package perspective
  :ensure t
  :demand t
  :custom
  ;; NOTE! I have also set 'SCP =' to open the perspective menu.
  ;; I'm only setting the additional binding because setting it
  ;; helps suppress an annoying warning message.
  (persp-mode-prefix-key (kbd "C-c M-p"))
  :init 
  (persp-mode)
  :config
  ;; Sets a file to write to when we save states
  (setq persp-state-default-file "~/.config/emacs/sessions"))

;; This will group buffers by persp-name in ibuffer.
(add-hook 'ibuffer-hook
          (lambda ()
            (persp-ibuffer-set-filter-groups)
            (unless (eq ibuffer-sorting-mode 'alphabetic)
              (ibuffer-do-sort-by-alphabetic))))

;; Automatically save perspective states to file when Emacs exits.
(add-hook 'kill-emacs-hook #'persp-state-save)

(use-package projectile
  :ensure t
  :config
  (projectile-mode 1))

(use-package rainbow-mode
  :ensure t
  :diminish
  :hook 
  ((org-mode prog-mode) . rainbow-mode))

(delete-selection-mode 1)    ;; You can select text and delete it by typing.
(electric-indent-mode -1)    ;; Turn off the weird indenting that Emacs does by default.
(electric-pair-mode 1)       ;; Turns on automatic parens pairing
;; The following prevents <> from auto-pairing when electric-pair-mode is on.
;; Otherwise, org-tempo is broken when you try to <s TAB...
(add-hook 'org-mode-hook (lambda ()
           (setq-local electric-pair-inhibit-predicate
                   `(lambda (c)
                  (if (char-equal c ?<) t (,electric-pair-inhibit-predicate c))))))
(global-auto-revert-mode t)  ;; Automatically show changes if the file has changed
(global-display-line-numbers-mode 1) ;; Display line numbers
(global-visual-line-mode t)  ;; Enable truncated lines
(menu-bar-mode -1)           ;; Disable the menu bar 
(scroll-bar-mode -1)         ;; Disable the scroll bar
(tool-bar-mode -1)           ;; Disable the tool bar
(setq org-edit-src-content-indentation 0) ;; Set src block automatic indent to 0 instead of 2.

(use-package eshell-syntax-highlighting
  :after esh-mode
  :ensure t
  :config
  (eshell-syntax-highlighting-global-mode +1))

;; eshell-syntax-highlighting -- adds fish/zsh-like syntax highlighting.
;; eshell-rc-script -- your profile for eshell; like a bashrc for eshell.
;; eshell-aliases-file -- sets an aliases file for the eshell.
  
(setq eshell-rc-script (concat user-emacs-directory "eshell/profile")
      eshell-aliases-file (concat user-emacs-directory "eshell/aliases")
      eshell-history-size 5000
      eshell-buffer-maximum-lines 5000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input t
      eshell-destroy-buffer-when-process-dies t
      eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh"))

(use-package vterm
  :ensure t
  :config
(setq shell-file-name "/bin/zsh"
      vterm-max-scrollback 5000))

(use-package vterm-toggle
  :after vterm
  :ensure t
  :config
  (setq vterm-toggle-fullscreen-p nil)
  (setq vterm-toggle-scope 'project)
  (add-to-list 'display-buffer-alist
               '((lambda (buffer-or-name _)
                     (let ((buffer (get-buffer buffer-or-name)))
                       (with-current-buffer buffer
                         (or (equal major-mode 'vterm-mode)
                             (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                  (display-buffer-reuse-window display-buffer-at-bottom)
                  ;;(display-buffer-reuse-window display-buffer-in-direction)
                  ;;display-buffer-in-direction/direction/dedicated is added in emacs27
                  ;;(direction . bottom)
                  ;;(dedicated . t) ;dedicated is supported in emacs27
                  (reusable-frames . visible)
                  (window-height . 0.3))))

(use-package sudo-edit :ensure t)

(add-to-list 'custom-theme-load-path "~/.config/emacs/themes/")
(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
	doom-themes-enable-italic t)
  (load-theme 'doom-zenburn t)
  (doom-themes-neotree-config)
  (doom-themes-org-config))

;; (load-theme 'kanagawa t)

(use-package tldr :ensure t)

(add-to-list 'default-frame-alist '(alpha-background . 100))

(use-package which-key
  :ensure t
  :demand t
  :init
    (which-key-mode 1)
  :diminish
  :config
  (setq which-key-side-window-location 'bottom
	  which-key-sort-order #'which-key-key-order-alpha
	  which-key-sort-uppercase-first nil
	  which-key-add-column-padding 1
	  which-key-max-display-columns nil
	  which-key-min-display-lines 6
	  which-key-side-window-slot -10
	  which-key-side-window-max-height 0.25
	  which-key-idle-delay 0.8
	  which-key-max-description-length 25
	  which-key-allow-imprecise-window-fit nil
	  which-key-separator " → " ))
