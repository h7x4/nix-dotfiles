{ config, pkgs, lib, machineVars, ... }:
let
  cfg = config.programs.thunderbird;
in
{
  programs.thunderbird = {
    enable = !machineVars.headless;
    profiles.h7x4 = {
      isDefault = true;
      withExternalGnupg = true;
    };
  };


  home.packages = lib.mkIf cfg.enable (with pkgs; [
    birdtray
  ]);
}
