{ config, pkgs, ... }:
let
  runtimeDir = "/run/user/${toString config.home.uid}";
  controlMastersDir = "${runtimeDir}/ssh-controlmasters";
in
{
  imports = [
    ./home.nix
    ./other.nix
    ./pvv.nix
  ];

  sops.secrets."ssh/secret-config" = {
    mode = "0444";
  };

  programs.ssh = {
    enable = true;
    includes = [
      config.sops.secrets."ssh/secret-config".path
      "${config.home.homeDirectory}/.ssh/mutable_config"
    ];

    controlMaster = "auto";
    controlPersist = "10m";
    controlPath = "${controlMastersDir}/%r@%h:%p";
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
}
