{ config, lib, pkgs, ... }:
let
  cfg = config.programs.emacs;

  configEl = pkgs.stdenv.mkDerivation {
    name = "config.el";
    src = ./.;

    buildInputs = with pkgs; [ emacs ];
    buildPhase = ''
      emacs --batch --eval "(require 'org)" --eval '(org-babel-tangle-file "config.org")'
    '';

    installPhase = ''
      cp config.el $out
    '';
  };

in
lib.mkIf cfg.enable {
  xdg.configFile."emacs/init.el".source = configEl.outPath;

  programs.emacs = {
    extraPackages = epkgs: with epkgs; [
      # gruber-darker-theme
      # recentf
      centaur-tabs
      company
      company-box
      company-coq
      counsel
      dashboard
      doom-modeline
      drag-stuff
      emojify
      envrc
      evil
      evil-collection
      evil-escape
      evil-nerd-commenter
      evil-org
      fira-code-mode
      flycheck
      general
      git-gutter
      helpful
      highlight-defined
      hl-todo
      ivy
      ivy-rich
      ivy-yasnippet
      lorem-ipsum
      lsp-ivy
      lsp-mode
      lsp-treemacs
      lsp-ui
      magit
      monokai-theme
      nix-mode
      org
      org-superstar
      projectile
      proof-general
      rainbow-delimiters
      ripgrep
      swiper
      treemacs
      treemacs-evil
      treemacs-icons-dired
      treemacs-magit
      treemacs-projectile
      use-package
      which-key
      writeroom-mode
      yasnippet
    ];
  };
}
