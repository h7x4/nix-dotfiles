{ config, ... }:
{
  programs.zoxide = {
    enableNushellIntegration = config.programs.nushell.enable;
  };
}
