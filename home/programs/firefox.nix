{ secrets, ... }:
{
  programs.firefox = {
    enable = true;
    profiles.h7x4 = {
      bookmarks = [{
        toolbar = true;
        bookmarks = secrets.browser.bookmarks;
      }];
      settings = {};
    };
  };
}
