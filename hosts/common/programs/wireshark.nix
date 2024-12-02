{ config, pkgs, ... }:
let
  inherit (config) machineVars;
in
{
  programs.wireshark = {
    enable = !config.machineVars.headless;
    package = pkgs.wireshark;
  };
}
