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
