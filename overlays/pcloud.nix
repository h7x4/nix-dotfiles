{ lib, pkgs }:
(_: _: {
  pcloud = pkgs.pcloud.overrideAttrs (prev: {
    buildInputs = prev.buildInputs ++ (with pkgs; [
      libappindicator
      libindicator
      libnotify
      xorg.libXScrnSaver
      xorg.libXtst
    ]);

    preFixup = ''
      rm "$out"/lib/libappindicator.so.1
      rm "$out"/lib/libindicator.so.7
      rm "$out"/lib/libnotify.so.4
      rm "$out"/lib/libXss.so.1
      rm "$out"/lib/libXtst.so.6
    '';
  });
})
