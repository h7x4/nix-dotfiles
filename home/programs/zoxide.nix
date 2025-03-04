{ config, ... }:
{
  programs.zoxide = {
    enable = true;
    enableNushellIntegration = config.programs.nushell.enable;
  };
}
