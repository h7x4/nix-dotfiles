{ config, lib, pkgs, ... }:
let
  cfg = config.programs.gpg;
in
lib.mkIf cfg.enable {
  programs.gpg = {
    homedir = "${config.xdg.configHome}/gnupg";

    auto-refresh-keys.enable = true;

    settings = {
      keyserver = [
        "hkps://keys.openpgp.org"
        "hkps://keyserver.ubuntu.com"
        "hkps://pgp.mit.edu"
      ];
    };

    key-fetchers.keyserver = {
      enable = true;
      keys = {
        "495A898FC1A0276F51EA3155355E5D82B18F4E71" = { trust = 4; };
        "490872D2A1D6451C9A3AA544D33368A59745C2F0" = { };
        "D231FBC3E4C3B668103982D8BC9E348039A74F7F" = { };
      };
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
    enableExtraSocket = true;
    enableSshSupport = true;
    enableScDaemon = true;
    enableNushellIntegration = config.programs.nushell.enable;
    grabKeyboardAndMouse = false;
  };
}
