{ pkgs, ... }: let

  xmonadHs = pkgs.stdenv.mkDerivation {
    name = "xmonad.hs";
    src = ./.;

    buildInputs = with pkgs; [ emacs ];
    buildPhase = ''
      emacs --batch --eval "(require 'org)" --eval '(org-babel-tangle-file "xmonad.org")'
    '';

    installPhase = ''
      cp xmonad.haskell $out
    '';
  };

in {
  home.file.".xmonad/xmonad.hs".source = xmonadHs.outPath;
}
