{ config, pkgs, ... }:
{
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    groovy
  ];

  programs.ssh.matchBlocks = {
    "tsuki-ws" = {
      user = "h7x4";
      hostname = "localhost";
      port = 10022;
    };

    "hildring pvv-login".proxyJump = "tsuki-ws";
    "drolsum pvv-login2 pvv".proxyJump = "tsuki-ws";
    "microbel pvv-users pvv-mail".proxyJump = "tsuki-ws";
  };

  programs.waybar.settings.mainBar.output = [ "DP-1" ];
}
