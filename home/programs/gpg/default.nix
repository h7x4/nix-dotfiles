{ pkgs, config, ... }:
{
  imports = [
    ./auto-refresh-keys.nix
  ];

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.configHome}/gnupg";

    auto-refresh-keys.enable = true;

    settings = {
      keyserver = [
        "hkps://keys.openpgp.org"
        "hkps://keyserver.ubuntu.com"
        "hkps://pgp.mit.edu"
      ];
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
    enableExtraSocket = true;
    enableSshSupport = true;
    enableScDaemon = true;
    grabKeyboardAndMouse = false;
  };
}
