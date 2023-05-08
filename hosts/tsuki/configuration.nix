{ config, lib, secrets, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")

    # ./services/calibre.nix
    ./services/gitea
    ./services/grafana
    ./services/headscale.nix
    ./services/hedgedoc.nix
    ./services/hydra.nix
    ./services/invidious.nix
    # ./services/jitsi.nix
    ./services/jupyter.nix
    ./services/kanidm.nix
    # ./services/keycloak.nix
    ./services/matrix
    ./services/minecraft
    ./services/nextcloud.nix
    ./services/nginx
    ./services/osuchan.nix
    ./services/pgadmin.nix
    ./services/plex.nix
    ./services/postgres.nix
    ./services/vscode-server.nix
  ];

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
    };
  };

  sops.secrets."drives/cirno/credentials" = {};

  fileSystems = let
    nfsDrive = drivename: {
      device = "10.0.0.36:/mnt/PoolsClosed/${drivename}";
      fsType = "nfs";
      options = [ "vers=3" "local_lock=all" ];
    };
  in {
    "/" = {
      device = "/dev/disk/by-uuid/54b9fd58-0df5-410c-ab87-766860967653";
      fsType = "btrfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/0A60-2885";
      fsType = "vfat";
    };

    "/data2/backup" = nfsDrive "backup";
    "/data2/momiji" = nfsDrive "momiji";
    "/data2/media" = nfsDrive "media";
    "/data2/postgres" = nfsDrive "postgres";
    "/data2/home" = nfsDrive "home";

    "/data2/cirno" = {
      device = "//10.0.0.36/cirno";
      fsType = "cifs";
      options = [
        "vers=3.0"
        "cred=${config.sops.secrets."drives/cirno/credentials".path}"
        "rw"
        "uid=1000"
      ];
    };
  };

  swapDevices = [{ device = "/dev/disk/by-uuid/92a1a33f-89a8-45de-a45e-6c303172cd7f"; }];

  virtualisation = {
    docker.enable = true;
  };

  boot = {
    initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];
    loader = {
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
  };
}
