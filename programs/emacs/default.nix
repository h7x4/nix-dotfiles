{ pkgs, ... }: let

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

in {
  home.file.".emacs".source = configEl.outPath;

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
    #   # package
      use-package
    #   evil
    #   evil-collection
    #   evil-nerd-commenter
    #   # org
    #   evil-org
    #   monokai-theme
    #   gruber-darker-theme
    #   company
    #   flycheck
    #   projectile
    #   yasnippet
    #   magit
    #   # recentf
    #   which-key
    ];
  };
}
