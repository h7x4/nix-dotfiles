{ config, lib, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix

      ../../pluggables/tools/programming.nix

      ./services/nginx.nix
      # ./services/dokuwiki.nix
      # ./services/gitlab
      ./services/gitea
      ./services/jitsi.nix
      # ./services/openldap.nix
      ./services/plex.nix
      ./services/hydra.nix
      ./services/matrix.nix
      # ./services/libvirt.nix
      ./services/grafana.nix
      # ./services/calibre.nix
      ./services/openvpn.nix
      # ./services/samba.nix
      ./services/searx.nix
      # ./services/syncthing.nix
    ];

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  # security.pam.services.login.unixAuth = true;

  boot.loader = {
    grub = {
      enable = true;
      version = 2;
      efiSupport = true;
      fsIdentifier = "label";
      device = "nodev";
      efiInstallAsRemovable = true;
    };
    # efi.efiSysMountPoint = "/boot/efi";
    # efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "Tsuki";
    networkmanager.enable = true;
    useDHCP = false;
    interfaces.ens18.useDHCP = true;
    firewall.enable=true;
  };

  services = {
    openssh.enable = true;
    printing.enable = true;
    cron = {
      enable = true;
      systemCronJobs = [
    #     "*/5 * * * *      root    date >> /tmp/cron.log"
      ];
    };
  };

  users = {
    groups.media = {};
    users.media = {
      isSystemUser = true;
      group = "media";
    };
  };

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };
}
