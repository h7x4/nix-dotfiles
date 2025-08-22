{ config, pkgs, lib, modulesPath, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ./services/atuin.nix
    ./services/borg.nix
    ./services/gitea-runners.nix
    ./services/grafana
    ./services/headscale.nix
    ./services/hedgedoc.nix
    ./services/kanidm.nix
    ./services/matrix
    ./services/minecraft
    ./services/nginx
    ./services/osuchan.nix
    ./services/plex.nix
    ./services/postgres.nix
    ./services/samba.nix
    ./services/taskserver.nix
    ./services/vaultwarden.nix
    ./services/vscode-server.nix
    ./services/wstunnel.nix

    ./services/scrapers/nhk-easy-news/default.nix
  ];

  system.stateVersion = "22.05";

  machineVars = {
    headless = true;
    dataDrives = {
      drives = {
        backup = "/data/backup";
        cirno = "/data/cirno";
        media = "/data/media";
        home = "/home";
      };
      default = "/data";
    };
  };

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  # security.pam.services.login.unixAuth = true;

  networking = {
    hostName = "tsuki";
    hostId = "8425e349";
    networkmanager.enable = true;
    interfaces.ens18.useDHCP = true;
    firewall.enable=true;
  };

  users = {
    users = {
      media = {
        description = "User responsible for owning all sorts of server media files";
        isSystemUser = true;
        group = "media";
      };
    };
    groups = {
      media = {};
      nix-builder = {};
    };
  };

  sops.secrets."drives/cirno/password" = { };
  sops.templates."drive-cirno.creds".content = ''
    username=h7x4
    password=${config.sops.placeholder."drives/cirno/password"}
  '';


  virtualisation = {
    docker.enable = true;
  };

  services.zfs.autoScrub.enable = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_6_15;
    zfs.requestEncryptionCredentials = false;
    zfs.package = pkgs.zfs_2_3;
    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        mirroredBoots = [
          { devices = [ "nodev" ]; path = "/boot"; }
        ];
      };
    };
  };
}
