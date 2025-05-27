{ config, pkgs, lib, ... }:
let
  cfg = config.wayland.windowManager.hyprland;
in {
  config = lib.mkIf cfg.enable {
    xdg.portal = {
      xdgOpenUsePortal = true;
      configPackages = with pkgs; [ gnome-session ];
      extraPortals = with pkgs; [
        gnome-keyring
        xdg-desktop-portal-gtk
        xdg-desktop-portal-termfilechooser
      ];
      config.hyprland = {
        default = "hyprland;gtk;";
        "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "gtk" ];
        "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
    };

    xdg.configFile."xdg-desktop-portal-termfilechooser/config".source =
      (pkgs.formats.ini { listsAsDuplicateKeys = true; }).generate "xdg-desktop-portal-termfilechooser.ini" {
        filechooser = {
          cmd = "${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh";
          default_dir = "$HOME";
          env = [
            "TERMCMD=alacritty -T \"Filechooser\" --class \"xdg-desktop-portal-termfilechooser\" --command"
          ];
        };
      };
  };
}
