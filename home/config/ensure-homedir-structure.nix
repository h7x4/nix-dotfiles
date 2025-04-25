{ config, ... }:
let
  home = config.home.homeDirectory;
  user = config.home.username;
in {
  systemd.user.tmpfiles.rules = [
    "d ${home}/SD - ${user} - - -"
    "d ${home}/ctf - ${user} - - -"
    "d ${home}/git - ${user} - - -"
    "d ${home}/pvv - ${user} - - -"
    "d ${home}/work - ${user} - - -"

    "d ${home}/pictures/icons - ${user} - - -"
    "d ${home}/pictures/photos - ${user} - - -"
    "d ${home}/pictures/screenshots - ${user} - - -"
    "d ${home}/pictures/stickers - ${user} - - -"
    "d ${home}/pictures/wallpapers - ${user} - - -"

    "d ${home}/documents/books - ${user} - - -"
    "d ${home}/documents/scans - ${user} - - -"

    "L ${home}/Downloads - ${user} - - ${home}/downloads"

    "L ${config.xdg.dataHome}/wallpapers - ${user} - - ${home}/pictures/wallpapers"
    "L ${config.home.sessionVariables.TEXMFHOME} - ${user} - - ${home}/git/texmf"
  ];
}
