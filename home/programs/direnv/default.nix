{ ... }:
{
  imports = [
    ./auto-prune.nix
  ];

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
