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
      "mutable_config"
    ];

    controlMaster = "auto";
    controlPersist = "10m";
    controlPath = "${controlMastersDir}/%r@%h:%p";
  };

  systemd.user.services."ssh-create-controlmasters-dir" = {
    Install.WantedBy = [ "default.target" ];
    Unit = {
      Description = "Create directory to store SSH control master sockets";
      ConditionPathExists = "!${controlMastersDir}";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/mkdir ${controlMastersDir}";
      Restart = "on-abort";
    };
  };
}
