{ lib, pkgs }:
(_: _: {
  pcloud = pkgs.pcloud.overrideAttrs (prev: {
    buildInputs = prev.buildInputs ++ (with pkgs; [
      gnome2.GConf
      libXScrnSaver
      libXtst
      libappindicator
      libindicator
      libnotify
    ]);

    preFixup = ''
      rm "$out"/lib/libappindicator3.so.1*
      rm "$out"/lib/libindicator3.so.7*
      rm "$out"/lib/libnotify.so.4*
      rm "$out"/lib/libXss.so.1*
      rm "$out"/lib/libXtst.so.6*
      rm "$out"/lib/libgconf-2.so.4*
      rmdir lib
    '';
  });
})
