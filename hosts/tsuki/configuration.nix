{ config, pkgs, lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")

    ./disk-config.nix
    ./hardware-configuration.nix

    ./services/atuin.nix
    # ./services/borg.nix
    # ./services/gitea-runners.nix
    # ./services/grafana
    # ./services/headscale.nix
    ./services/hedgedoc.nix
    ./services/kanidm.nix
    ./services/matrix
    # ./services/minecraft
    ./services/nginx
    # ./services/plex.nix
    ./services/postgres.nix
    # ./services/samba.nix
    # ./services/taskserver.nix
    ./services/vaultwarden.nix
    # ./services/vscode-server.nix
    # ./services/wstunnel.nix

    # ./services/scrapers/nhk-easy-news/default.nix
  ];

  system.stateVersion = "25.05";

  machineVars = {
    headless = true;
    dataDrives = {
      drives = {
        backup = "/data/backup";
        # cirno = "/data/cirno";
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
    hostId = "1cb0971f";
    firewall.enable = true;
  };

  systemd.network = {
    enable = true;
    wait-online.anyInterface = true;
    networks."30-ether" = {
      matchConfig.Type = "ether";
      dns = [ "1.1.1.1" "8.8.8.8" ];
      domains = [ "nani.wtf" ];
      DHCP = "ipv4";
    };
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

  # sops.secrets."drives/cirno/password" = { };
  # sops.templates."drive-cirno.creds".content = ''
  #   username=h7x4
  #   password=${config.sops.placeholder."drives/cirno/password"}
  # '';

  sops.secrets."boot/ntfy_key" = { };

  virtualisation = {
    docker.enable = true;
  };

  services.resolved.settings.Resolve.MulticastDNS = false;

  services.zfs.trim.enable = true;
  services.zfs.autoScrub.enable = true;

  boot.initrd = {
    secrets = {
      # NOTE: this means that sops already needs to have installed this key at
      #       its path before rebuilding once again.
      "/secrets/boot/ntfy_key" = config.sops.secrets."boot/ntfy_key".path;
    };

    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 22;
        authorizedKeys = [
          "command=\"systemctl default\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0aYHsiqfLCA0prSmEi6hZeQPCGxZYR7gp+3U99POUWJyycSVqXMhgVZHT8VEYGf+EZ/y5nL1bvna7ChBwQBzInB2mRW+TCLL3h1w9t/27vTHe3wV+fowTooD/paOErmWFO4yDBEJ3cYFMXowAd3GfvsBSFGPSsvSxghSzWj+kfhIFkXD02LZxn/hBQyCT6irp3Hwx1cBu8ic/l2ln64SLARuEmj4ITaafNC5wD2Gr5Jf3q+T9QtJeFPXSpJD7MtVMJ1VpgpfGBvlEYKggiQjxgu2BXHv1w3KIfyltTwhrcqHvttaJSuR5TreAgQ5+dZHmMr6XX8rFG+HEa8gND6NjGjHrJBxp53qgPtLAmBddvf8xQMYiq6+XST16nlRaAsjU3yr3VqCt7XhJiS2IV8JiIV3dok8nxzDX9sjdZeGchdnAnU6lcxDgnBvAcJRaWHwMCG8Ty9sJ4otgjr5A1GxRBndJIIuKzjpdtsrCAHg/K2zqFoKPJxN/K9zDWKNy0aEy2Akl3LgHF2QIuG5pUOmbyvbF8AoTudaz6Zu6JpVwOb9T9avFJBH4RHQ3mK0faBkrEmnkAg6JnDDMIt0XLALl88rI4kbdkVvJ2kaodvq799TCCw1PwMidgWX63LemWVBx+CL9ebXrsOkOthhMhkeaFXY9Am3Ee7rfD1tq3PGU1w== h7x4"
        ];
        hostKeys = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
    };

    systemd = {
      enable = true;
      network.enable = true;
      network.networks = { inherit (config.systemd.network.networks) "30-ether"; };
      network.wait-online.enable = true;
      network.wait-online.anyInterface = true;

      storePaths = with pkgs; [
        cacert
        coreutils
        curl
      ];

      # services.systemd-networkd.environment."SYSTEMD_LOG_LEVEL" = "debug";

      services.notify-remote-disk-unlock = {
        description = "Remote Disk Unlocking Notifier";
        wantedBy = [ "initrd.target" ];
        after = [ "network-online.target" ];
        serviceConfig.Type = "oneshot";
        environment.NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        script = ''
          export NTFY_KEY="$('${lib.getExe' pkgs.coreutils "cat"}' '/secrets/boot/ntfy_key')"

          '${lib.getExe pkgs.curl}' \
           -H "Title: tsuki reached ZFS unlocking stage" \
           -d "Please log in and fix :)" \
           "https://ntfy.sh/$NTFY_KEY"
        '';
      };
    };
  };

  boot.kernelPackages = pkgs.linuxPackages;
  boot.zfs.package = pkgs.zfs_2_4;
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
    systemd-boot.consoleMode = "1";
    # zfs.requestEncryptionCredentials = false;
  };
}
