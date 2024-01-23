{ pkgs, unstable-pkgs, secrets, ... }:
{
  # Follow instructions for setup:
  # https://gist.github.com/joepie91/c26f01a787af87a96f967219234a8723
  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.nani.wtf";
    listenHost = "localhost";
    notificationSender = "hydra@nani.wtf";
    useSubstitutes = true;
    package = unstable-pkgs.hydra_unstable;
    buildMachinesFiles = [];
    dbi = "dbi:Pg:dbname=hydra;host=/var/run/postgresql;user=hydra;";
  };

  systemd.slices.system-hydra = {
    description = "Nix Hydra slice";
    requires = [
      "system.slice"
      "postgresql.service"
    ];
    after = [ "system.slice" ];
  };

  systemd.services = {
    hydra-evaluator.serviceConfig.Slice = "system-hydra.slice";
    hydra-init.serviceConfig.Slice = "system-hydra.slice";
    hydra-notify.serviceConfig.Slice = "system-hydra.slice";
    hydra-queue-runner.serviceConfig.Slice = "system-hydra.slice";
    hydra-send-stats.serviceConfig.Slice = "system-hydra.slice";
    hydra-server.serviceConfig.Slice = "system-hydra.slice";
  };

  systemd.timers = {
    hydra-check-space.timerConfig.Slice = "system-hydra.slice";
    hydra-compress-logs.timerConfig.Slice = "system-hydra.slice";
    hydra-update-gc-roots.timerConfig.Slice = "system-hydra.slice";
  };

  systemd.services.hydra-server.serviceConfig = {
    Slice = "system-hydra.slice";
    ReadOnlyPaths = [
      "/nix/"
      "/var/lib/hydra/scm/"
    ];
    ReadWritePaths = [
      "/nix/var/nix/gcroots/hydra/"
      "/nix/var/nix/daemon-socket/socket"
    ];

    LockPersonality = true;
    # MemoryDenyWriteExecute = false;
    NoNewPrivileges = true;
    PermissionsStartOnly = true;
    PrivateDevices = true;
    PrivateMounts = true;
    # PrivateNetwork=false
    PrivateTmp = true;
    PrivateUsers = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectSystem = "strict";
    RemoveIPC = true;
    Restart = "always";
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    # StateDirectory=hydra/www
    # StateDirectoryMode=700
    SystemCallArchitectures = "native";
    SystemCallFilter = "@system-service";
  };
}
