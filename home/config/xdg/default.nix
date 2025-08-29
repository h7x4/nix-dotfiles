{ config, lib, ... }:
let
  cfg = config.xdg.userDirs;

in
{
  imports = [
    ./mimetypes.nix
    ./directory-spec-overrides.nix
  ];

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      desktop = lib.mkDefault "${config.home.homeDirectory}/Desktop";
      documents = lib.mkDefault "${config.home.homeDirectory}/documents";
      download = lib.mkDefault "${config.home.homeDirectory}/downloads";
      music = lib.mkDefault "${config.home.homeDirectory}/music";
      pictures = lib.mkDefault "${config.home.homeDirectory}/pictures";
      publicShare = lib.mkDefault "${config.home.homeDirectory}/public";
      templates = lib.mkDefault "${config.home.homeDirectory}/templates";
      videos = lib.mkDefault "${config.home.homeDirectory}/videos";
    };
  };

  home.sessionVariables.XDG_SCREENSHOTS_DIR = "${cfg.pictures}/screenshots";

  systemd.user.tmpfiles.settings."05-xdg-userdirs" = let
    dirCfg = {
      d = {
        user = config.home.username;
        mode = "0700";
      };
    };
  in {
    "${cfg.desktop}" = dirCfg;
    "${cfg.documents}" = dirCfg;
    "${cfg.download}" = dirCfg;
    "${cfg.music}" = dirCfg;
    "${cfg.pictures}" = dirCfg;
    "${cfg.publicShare}" = dirCfg;
    "${cfg.templates}" = dirCfg;
    "${cfg.videos}" = dirCfg;
    "${config.home.sessionVariables.XDG_SCREENSHOTS_DIR}" = dirCfg;
  };
}
