{ config, ... }:
{
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    enableNushellIntegration = config.programs.nushell.enable;

    auto-prune-allowed-dirs.enable = true;
  };
}
