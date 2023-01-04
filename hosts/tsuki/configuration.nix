{ secrets, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./extra-hardware-configuration.nix

    # ./services/calibre.nix
    ./services/gitea
    ./services/grafana
    ./services/hydra.nix
    # ./services/jitsi.nix
    ./services/jupyter.nix
    # ./services/keycloak.nix
    ./services/matrix
    ./services/nginx
    ./services/osuchan.nix
    ./services/plex.nix
    ./services/postgres.nix
    ./services/vscode-server.nix
  ];

  # TODO: See ../common.nix
  services.xserver.enable = false;
  services.xserver.displayManager.lightdm.enable = false;

  machineVars = {
    headless = true;
    dataDrives = {
      drives = {
        backup = "/data2/backup";
        momiji = "/data2/momiji";
        cirno = "/data2/cirno";
        media = "/data2/media";
        postgres = "/data2/postgres";
        home = "/data2/home";
      };
      default = "/data2/momiji";
    };
  };

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
    users = {
      media = {
        description = "User responsible for owning all sorts of server media files";
        isSystemUser = true;
        group = "media";
      };
      nix-builder = {
        description = "User for executing distributed builds via SSH";
        isSystemUser = true;
        group = "nix-builder";
        openssh.authorizedKeys.keyFiles = [ secrets.keys.ssh.nixBuilders.tsuki.public ];
      };
    };
    groups = {
      media = {};
      nix-builder = {};
    };
  };

  virtualisation = {
    docker.enable = true;
  };
}
