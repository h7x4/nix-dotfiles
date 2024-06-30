{ config, ... }:
{
  home.stateVersion = "22.05";

  programs.git.extraConfig.maintenance.repo = let
    home = config.home.homeDirectory;
  in [
    "${home}/nix"
    "${home}/nixpkgs"
    "${home}/pvv/nix"
  ];
}