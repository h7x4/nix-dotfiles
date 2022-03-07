{ pkgs, ... }:
{
  services.dunst = {
    enable = true;
    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
      size = "32x32";
    };
    settings = {
      global = {
        geometry = "300x5-30+50";
        transparency = 10;
        frame_color = "#eceff1";
        font = "Droid Sans 9";
      };
      urgency_normal = {
        background = "#37474f";
        foreground = "#eceff1";
        timeout = 10;
      };
    };
  };
}
