{ config, ... }:
{
  home.stateVersion = "24.05";

  programs.ssh.matchBlocks = {
    "tsuki-ws" = {
      user = "h7x4";
      hostname = "localhost";
      port = 10022;
    };

    "hildring pvv-login pvv".proxyJump = "tsuki-ws";
  };

  sops.secrets."git/nordicsemi-maintenance-repos-config" = { };

  programs.git.includes = [
    { path = config.sops.secrets."git/nordicsemi-maintenance-repos-config".path; }
  ];
}