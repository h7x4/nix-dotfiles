{ ... }:
{
  services.picom = {
    # See https://github.com/NixOS/nixpkgs/issues/206663
    enable = false;

    fade = true;
    fadeSteps = [ 0.1 0.1 ];
    fadeExclude = [];

    shadow = true;
    shadowOffsets = [ (-7) (-7) ];
    shadowOpacity = 0.25;
    shadowExclude = [
      "class_g = 'XAVA'"
      "class_g = 'stalonetray'"
      "class_g = 'lattedock'"
      "class_g = 'latte-dock'"
    ];

    vSync = true;
  };
}
