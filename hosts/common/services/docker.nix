{ config, lib, ... }:
let
  cfg = config.virtualisation.docker;
in
{
  virtualisation.docker.enableOnBoot = lib.mkDefault false;
  virtualisation.docker.autoPrune = {
    enable = lib.mkDefault cfg.enable;
    flags = [ "--all" ];
    dates = "daily";
  };
}
