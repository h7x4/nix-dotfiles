{ config, lib, ... }:
let
  cfg = config.programs.fzf;
in
{
  programs.fzf = {
    defaultCommand = "fd --type f";
  };
}
