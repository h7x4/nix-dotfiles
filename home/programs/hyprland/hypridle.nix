{ config, pkgs, lib, ... }:
let
  cfg = config.wayland.windowManager.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          ignore_dbus_inhibit = false;
          lock_cmd = "pidof hyprlock || ${config.programs.hyprlock.package}/bin/hyprlock";
          before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
          after_sleep_cmd = "${cfg.finalPackage}/bin/hyprctl dispatch dpms on";
        };

        listener = [
          {
            timeout = 900;
            on-timeout = "${config.programs.hyprlock.package}/bin/hyprlock";
          }
          {
            timeout = 1200;
            on-timeout = "${cfg.finalPackage}/bin/hyprctl dispatch dpms off";
            on-resume = "${cfg.finalPackage}/bin/hyprctl dispatch dpms on";
          }
        ];
      };
    };

    systemd.user.services.hypridle = {
      Unit.After = lib.mkForce "graphical-session.target";
      Service.Slice = "session.slice";
    };
  };
}
