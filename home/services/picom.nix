{ ... }:
{
  services.picom = {
    enable = true;

    blur = true;
    blurExclude = [
      "class_g = 'slop'"
      "class_g = 'XAVA'"
      "class_g = 'lattedock'"
      "class_g = 'latte-dock'"
      "window_type = 'dock'"
      "window_type = 'desktop'"
      "_GTK_FRAME_EXTENTS@:c"
    ];

    fade = true;
    fadeSteps = [ "0.1" "0.1" ];
    fadeExclude = [];

    shadow = true;
    shadowOffsets = [ (-7) (-7) ];
    shadowOpacity = "0.25";
    shadowExclude = [
      "class_g = 'XAVA'"
      "class_g = 'stalonetray'"
      "class_g = 'lattedock'"
      "class_g = 'latte-dock'"
    ];
    noDockShadow = true;
    noDNDShadow = true;

    vSync = true;

    extraOptions = '''';
  };
}
