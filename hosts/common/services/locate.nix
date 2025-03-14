{ pkgs, ... }:
{
  services.locate = {
    enable = true;
    package = pkgs.plocate;
    localuser = null;
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
