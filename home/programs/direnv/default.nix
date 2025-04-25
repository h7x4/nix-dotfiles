{ config, ... }:
{
  programs.direnv = {
    enable = true;
    silent = true;

    nix-direnv.enable = true;

    enableZshIntegration = true;
    enableNushellIntegration = config.programs.nushell.enable;

    auto-prune-allowed-dirs.enable = true;
  };
}
