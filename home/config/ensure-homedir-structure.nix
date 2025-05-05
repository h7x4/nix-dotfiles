{ config, ... }:
{
  systemd.user.tmpfiles.settings."05-homedir" = let
    home = config.home.homeDirectory;
    user = config.home.username;

    defaultDirConf = {
      d = {
        inherit user;
      };
    };

    symlink = target: {
      L = {
        inherit user;
        argument = target;
      };
    };
  in {
    "${home}/SD" = defaultDirConf;
    "${home}/ctf" = defaultDirConf;
    "${home}/git" = defaultDirConf;
    "${home}/pvv" = defaultDirConf;
    "${home}/work" = defaultDirConf;

    "${home}/pictures/icons" = defaultDirConf;
    "${home}/pictures/photos" = defaultDirConf;
    "${home}/pictures/screenshots" = defaultDirConf;
    "${home}/pictures/stickers" = defaultDirConf;
    "${home}/pictures/wallpapers" = defaultDirConf;

    "${home}/documents/books" = defaultDirConf;
    "${home}/documents/scans" = defaultDirConf;

    "${home}/Downloads" = symlink "${home}/downloads";

    "${config.xdg.dataHome}/wallpapers" = symlink "${home}/pictures/wallpapers";
    "${config.home.sessionVariables.TEXMFHOME}" = symlink "${home}/git/texmf";
  };
}
