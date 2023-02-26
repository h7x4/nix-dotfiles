{ pkgs, secrets, ... }:
{
  programs.firefox = {
    enable = true;
    profiles.h7x4 = {
      bookmarks = [{
        toolbar = true;
        bookmarks = secrets.browser.bookmarks;
      }];
      search = {
        default = "Google";
        engines = secrets.browser.engines { inherit pkgs; };
        force = true;
      };
      settings = {};
    };
  };
}
