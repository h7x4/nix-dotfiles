{ config, lib, ... }:
let
  cfg = config.programs.eza;
in
{
  programs.eza = {
    icons = "auto";
    enableNushellIntegration = config.programs.nushell.enable;
  };
}
