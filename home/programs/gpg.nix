{ config, ... }:
{
  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.configHome}/gnupg";
    # TODO: declare public keys and trust declaratively
    # mutableKeys = false;
    # mutableTrust = false;
    # publicKeys = [];
    # settings = {

    # };
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "curses";
    enableExtraSocket = true;
    enableSshSupport = true;
    enableScDaemon = true;
    grabKeyboardAndMouse = false;
  };
}
