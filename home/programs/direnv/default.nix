{ config, lib, ... }:
let
  cfg = config.programs.direnv;
in
{
  programs.direnv = {
    silent = true;

    nix-direnv.enable = true;

    enableZshIntegration = true;
    enableNushellIntegration = config.programs.nushell.enable;

    auto-prune-allowed-dirs.enable = true;
  };
}
