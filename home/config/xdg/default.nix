{ config, lib, ... }:
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
      download = lib.mkDefault "${config.home.homeDirectory}/Downloads";
      music = lib.mkDefault "${config.home.homeDirectory}/music";
      pictures = lib.mkDefault "${config.home.homeDirectory}/pictures";
      publicShare = lib.mkDefault "${config.home.homeDirectory}/public";
      templates = lib.mkDefault "${config.home.homeDirectory}/templates";
      videos = lib.mkDefault "${config.home.homeDirectory}/videos";
    };
  };
}
