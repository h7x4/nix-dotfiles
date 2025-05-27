{ config, lib, machineVars, ... }:
let
  cfg = config.services.gnome-keyring;
in
{
  services.gnome-keyring.enable = !machineVars.headless;

  systemd.user.services.gnome-keyring.Service.Slice = lib.mkIf cfg.enable "session.slice";
}
