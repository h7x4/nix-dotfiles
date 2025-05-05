{ config, ... }:
{
  systemd.user.tmpfiles.settings."05-homedir" = let
    home = config.home.homeDirectory;
    user = config.home.username;

    defaultDirConf = {
      d = {
        inherit user;
        mode = "0700";
      };
    };

    symlink = target: {
      L = {
        inherit user;
        argument = target;
        mode = "0600";
      };
    };
  in {
    "${home}/SD" = defaultDirConf;
    "${home}/ctf" = defaultDirConf;
    "${home}/git" = defaultDirConf;
    "${home}/pvv" = defaultDirConf;
    "${home}/tmp" = defaultDirConf;
    "${home}/work" = defaultDirConf;

    "${home}/pictures/icons" = defaultDirConf;
    "${home}/pictures/photos" = defaultDirConf;
    "${home}/pictures/screenshots" = defaultDirConf;
    "${home}/pictures/stickers" = defaultDirConf;
    "${home}/pictures/wallpapers" = defaultDirConf;

    "${home}/documents/books" = defaultDirConf;
    "${home}/documents/manuals" = defaultDirConf;
    "${home}/documents/music-sheets" = defaultDirConf;
    "${home}/documents/scans" = defaultDirConf;
    "${home}/documents/schematics" = defaultDirConf;

    "${home}/Downloads" = symlink "${home}/downloads";

    "${config.xdg.dataHome}/wallpapers" = symlink "${home}/pictures/wallpapers";
    "${config.home.sessionVariables.TEXMFHOME}" = symlink "${home}/git/texmf";
  };
}
