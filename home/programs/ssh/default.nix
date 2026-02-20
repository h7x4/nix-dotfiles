{ config, lib, pkgs, ... }:
let
  cfg = config.programs.ssh;
  runtimeDir = "/run/user/${toString config.home.uid}";
  controlMastersDir = "${runtimeDir}/ssh";
in
{
  imports = [
    ./home.nix
    ./other.nix
    ./pvv.nix
    ./kyoto-u.nix
  ];
  config = lib.mkIf cfg.enable {

    sops.secrets."ssh/secret-config" = {
      mode = "0444";
    };

    programs.ssh = {
      includes = [
        config.sops.secrets."ssh/secret-config".path
        "${config.home.homeDirectory}/.ssh/mutable_config"
      ];

      enableDefaultConfig = false;

      matchBlocks."*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        # controlPersist = "10m";
        controlPersist = "no";
        controlMaster = "auto";
        controlPath = "${controlMastersDir}/%n%C";
      };
    };

    systemd.user.tmpfiles.settings."10-ssh" = {
      ${controlMastersDir}.d = {
        user = config.home.username;
        mode = "0700";
      };
      "${config.home.homeDirectory}/.ssh/mutable_config".f = {
        user = config.home.username;
        mode = "0600";
      };
    };
  };
}
