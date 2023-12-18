{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    profiles.h7x4 = {
      bookmarks = [{
        toolbar = true;
        bookmarks = import ./browser/bookmarks.nix;
      }];
      search = {
        default = "Google";
        engines = import ./browser/engines.nix { inherit pkgs; };
        force = true;
      };
      settings = {};
    };
  };
}
