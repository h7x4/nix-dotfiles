{ config, ... }:
{
  programs.eza = {
    enable = true;
    icons = "auto";
    enableNushellIntegration = config.programs.nushell.enable;
  };
}
