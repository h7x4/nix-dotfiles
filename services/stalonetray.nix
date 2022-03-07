{ colorTheme, ... }:
{
  services.stalonetray = {
    enable = true;
    config = {
      decorations = "none";
      transparent = false;
      dockapp_mode = "none";
      geometry = "8x1-0+0";
      background = colorTheme.default.background;
      kludges = "force_icons_size";
      grow_gravity = "NW";
      icon_gravity = "NW";
      icon_size = 30;
      sticky = true;
      window_type = "dock";
      window_layer = "bottom";
      no_shrink = true;
      skip_taskbar = true;
      slot_size = 40;
    };
  };
}
