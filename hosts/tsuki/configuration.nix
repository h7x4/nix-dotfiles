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
    ./services/osuchan.nix
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

  # sops.secrets."drives/cirno/password" = { };
  # sops.templates."drive-cirno.creds".content = ''
  #   username=h7x4
  #   password=${config.sops.placeholder."drives/cirno/password"}
  # '';


  virtualisation = {
    docker.enable = true;
  };

  services.resolved.extraConfig = ''
    MulticastDNS=no
  '';

  services.zfs.trim.enable = true;
  services.zfs.autoScrub.enable = true;

  boot.initrd = {
    network = {
      enable = true;
      udhcpc.enable = true;
      flushBeforeStage2 = true;
      ssh = {
        enable = true;
        port = 22;
        authorizedKeys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0aYHsiqfLCA0prSmEi6hZeQPCGxZYR7gp+3U99POUWJyycSVqXMhgVZHT8VEYGf+EZ/y5nL1bvna7ChBwQBzInB2mRW+TCLL3h1w9t/27vTHe3wV+fowTooD/paOErmWFO4yDBEJ3cYFMXowAd3GfvsBSFGPSsvSxghSzWj+kfhIFkXD02LZxn/hBQyCT6irp3Hwx1cBu8ic/l2ln64SLARuEmj4ITaafNC5wD2Gr5Jf3q+T9QtJeFPXSpJD7MtVMJ1VpgpfGBvlEYKggiQjxgu2BXHv1w3KIfyltTwhrcqHvttaJSuR5TreAgQ5+dZHmMr6XX8rFG+HEa8gND6NjGjHrJBxp53qgPtLAmBddvf8xQMYiq6+XST16nlRaAsjU3yr3VqCt7XhJiS2IV8JiIV3dok8nxzDX9sjdZeGchdnAnU6lcxDgnBvAcJRaWHwMCG8Ty9sJ4otgjr5A1GxRBndJIIuKzjpdtsrCAHg/K2zqFoKPJxN/K9zDWKNy0aEy2Akl3LgHF2QIuG5pUOmbyvbF8AoTudaz6Zu6JpVwOb9T9avFJBH4RHQ3mK0faBkrEmnkAg6JnDDMIt0XLALl88rI4kbdkVvJ2kaodvq799TCCw1PwMidgWX63LemWVBx+CL9ebXrsOkOthhMhkeaFXY9Am3Ee7rfD1tq3PGU1w== h7x4"
        ];
        hostKeys = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
      postCommands = ''
        export NIX_SSL_CERT_FILE='${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt'

        echo 'zfs load-key -a; killall zfs; exit' >> /root/.profile
      '';
    };
  };

  boot.kernelPackages = pkgs.linuxPackages;
  boot.zfs.package = pkgs.zfs_2_3;
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
    systemd-boot.consoleMode = "1";
    # zfs.requestEncryptionCredentials = false;
  };
}
