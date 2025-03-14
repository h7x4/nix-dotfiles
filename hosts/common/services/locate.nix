{ pkgs, ... }:
{
  services.locate = {
    enable = true;
    package = pkgs.plocate;
    pruneNames = [
      ".bzr"
      ".cache"
      ".git"
      ".hg"
      ".svn"

      ".direnv"
      "target"
    ];
  };
}
