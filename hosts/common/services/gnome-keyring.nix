{ config, lib, ... }:
let
  cfg = config.services.gnome.gnome-keyring;
in
{
  services.gnome.gnome-keyring.enable = !config.machineVars.headless;

  systemd.user.services.gnome-keyring.serviceConfig.Slice = lib.mkIf cfg.enable "session.slice";
}
