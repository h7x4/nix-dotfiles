{ pkgs, config, machineVars, ... }:
{
  gtk = pkgs.lib.mkIf (!machineVars.headless) {
    enable = true;
    font.name = "Droid Sans";

    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

    gtk3.bookmarks = map (s: "file://${config.home.homeDirectory}/${s}") [
      "Downloads"
      "pictures"
      "documents"
      "music"
      ".config"
      ".local/share"
      "SD"
      "git"
      "pvv"
      "nix"
      "work"
      "ctf"
    ];
  };
}
