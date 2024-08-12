{ pkgs, lib, ... }:
{
  imports = [
    ./auto-update-tldr-db.nix
  ];

  programs.tealdeer.enable = true;
}
