{ config, ... }:
{
  home.stateVersion = "24.11";

  programs.waybar.settings.mainBar.output = [ "eDP-1" ];
}
