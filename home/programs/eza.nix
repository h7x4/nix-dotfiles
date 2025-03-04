{ config, ... }:
{
  programs.eza = {
    enable = true;
    enableNushellIntegration = config.programs.nushell.enable;
  };
}
