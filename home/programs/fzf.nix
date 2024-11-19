{ ... }:
{
  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f";
  };
}