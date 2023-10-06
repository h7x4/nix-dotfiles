{ config, lib, ... }: let
  cfg = config.services.borgbackup;
in {
  services.borgbackup.jobs = let
    createJob = path: endpoint: {
      paths = path;
      encryption.mode = "none";
      environment.BORG_RSH = "ssh -i /home/h7x4/.ssh/id_rsa";
      repo = "ssh://h7x4@10.0.0.220/mnt/SSD1/backup/${endpoint}";
      compression = "auto,zstd";
      startAt = "daily";
    };
  in {
    postgres = createJob config.services.postgresqlBackup.location "postgres";
    minecraft = createJob config.services.minecraft-servers.dataDir "minecraft";
    gitea = createJob config.services.gitea.dump.backupDir "gitea";
  };

  systemd.services = lib.mkMerge ((lib.flip map) (builtins.attrNames cfg.jobs) (name: {
    "borgbackup-job-${name}".serviceConfig = {
      # DynamicUser = true;
      BindReadOnlyPaths = [
        "/home/h7x4/.ssh/id_rsa"
        cfg.jobs.${name}.paths
      ];
      # IPAddressAllow="10.0.0.220";

      # hardening
      # CapabilityBoundingSet = "";
      LockPersonality = true;
      # MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      # PrivateMounts = true;
      # PrivateTmp = true;
      # PrivateUsers = true;
      ProtectClock = true;
      # ProtectHome = "read-only";
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      # ProtectSystem = "strict";
      RemoveIPC = true;
      RestrictSUIDSGID = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
      ];
      # SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
      ];
      UMask = "0077";
    };
  }));
}
