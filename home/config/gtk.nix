{ pkgs, config, ... }:
{
  gtk = pkgs.lib.mkIf (!config.machineVars.headless) {
    enable = true;
    font = {
      name = "Droid Sans";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus";
    };
    theme = {
      package = pkgs.vimix-gtk-themes;
      name = "VimixDark";
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

    gtk3.bookmarks = map (s: "file://${config.home.homeDirectory}/${s}") [
      "Dropbox"
      "Downloads"
      "git/pvv"
      "nix"
      "NTNU"
      "ng"
      "git"
      "music"
    ];
  };
}
