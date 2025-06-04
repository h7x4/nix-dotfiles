{ config, pkgs, lib, machineVars, ... }:
let
  cfg = config.programs.thunderbird;
in
lib.mkIf cfg.enable {
  programs.thunderbird = {
    profiles.h7x4 = {
      isDefault = true;
      withExternalGnupg = true;
    };
  };

  home.packages = with pkgs; [
    birdtray
  ];
}
