{ pkgs, config, machineVars, ... }:
{
  gtk = pkgs.lib.mkIf (!machineVars.headless) {
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
      "Downloads"
      "pictures"
      "documents"
      "music"
      ".config"
      ".local/share"
      # "Dropbox"
      "git"
      "git/pvv"
      "nix"
      "work"
      "ctf"
    ];
  };
}
