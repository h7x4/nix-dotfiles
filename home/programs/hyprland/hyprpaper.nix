{ config, lib, ... }:
let
  cfg = config.wayland.windowManager.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    services.hyprpaper = {
      enable = true;
      settings.ipc = true;
    };

    systemd.user.services.hyprpaper = {
      Unit.After = lib.mkForce "graphical-session.target";
      Service.Slice = "session.slice";
    };
  };
}
