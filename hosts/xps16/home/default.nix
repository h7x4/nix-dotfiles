{ config, ... }:
{
  home.stateVersion = "24.11";

  programs.waybar.settings.mainBar.output = [ "eDP-1" "DP-7" ];

  wayland.windowManager.hyprland.settings = {
    monitor = [
      "eDP-1, 3840x2400@90.00Hz, 0x0, 2"

      # Office, childhood home
      "desc:Dell Inc. DELL U2713H C6F0K52E19AL, 2560x1440, 1920x0, 1"
      "desc:Dell Inc. DELL U2713H C6F0K3CH0MUL, 2560x1440, ${toString (1920 + 2560)}x0, 1"

      # PVV
      "desc:ASUSTek COMPUTER INC MG248 K2LMQS048969, 1920x1080@60.00Hz, -1920x0, 1"
      "desc:Ancor Communications Inc MG248 G7LMQS010063, 1920x1080@60.00Hz, -${toString (1920 * 2)}x0, 1"
    ];
  };
}
