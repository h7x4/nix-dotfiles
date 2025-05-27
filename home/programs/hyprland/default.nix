{ config, pkgs, lib, ... }:
let
  cfg = config.wayland.windowManager.hyprland;
in
{
  imports = [
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./hyprpolkitagent.nix
    ./keybinds.nix
    ./scratchpads.nix
    ./windowrules.nix
    ./xdg-portals.nix
  ];

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      WLR_RENDERER_ALLOW_SOFTWARE = "1";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      GDK_BACKEND = "wayland,x11,*";
      QT_QPA_PLATFORM = "wayland;xcb";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      SDL_VIDEODRIVER = "wayland";
      OZONE_PLATFORM = "wayland";
      CLUTTER_BACKEND = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      # QT_QPA_PLATFORMTHEME = "qt6ct";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";

      # LIBVA_DRIVER_NAME = "nvidia";
      # GBM_BACKEND = "nvidia-drm";
      # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };

    home.packages = with pkgs; [
      wl-clipboard-rs
    ];

    systemd.user.services = {
      waybar.Unit.After = lib.mkForce "graphical-session.target";

      network-manager-applet.Unit.After = lib.mkForce "graphical-session.target";

      fcitx5-daemon = {
        Unit.After = lib.mkForce "graphical-session.target";
        Service.Slice = "session.slice";
      };
    };
  };
}
