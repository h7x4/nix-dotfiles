{ config, lib, ... }:
let
  cfg = config.wayland.windowManager.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    services.hyprpolkitagent.enable = true;

    systemd.user.services.hyprpolkitagent = {
      Unit.After = lib.mkForce "graphical-session.target";
      Service.Slice = "session.slice";
    };
  };
}
