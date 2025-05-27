{ config, lib, ... }:
let
  cfg = config.programs.dconf;
in
{
  programs.dconf.enable = !config.machineVars.headless;

  systemd.user.services.dconf.serviceConfig.slice = lib.mkIf cfg.enable "session.slice";
}
