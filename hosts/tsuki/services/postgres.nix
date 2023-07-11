{ config, pkgs, lib, secrets, ... }: let
  cfg = config.services.postgresql;
in {
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      local hydra all ident map=hydra-users
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
    port = secrets.ports.postgres;
    dataDir = "${config.machineVars.dataDrives.drives.postgres}/${config.services.postgresql.package.psqlSchema}";
    settings = {
      max_connections = 150;
    };
  };

  services.postgresqlBackup = {
    enable = true;
    location = "${config.machineVars.dataDrives.drives.backup}/postgres";
    backupAll = true;
  };

  systemd.services.postgresqlBackup = {
    requires = [ "postgresql.service" "data2-backup.mount" ];
  };

  systemd.services.postgresql = {
    requires = [ "data2-postgres.mount" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = 3;
      ReadWritePaths = [ cfg.dataDir ];
      NoNewPrivileges = true;
      PrivateDevices = true;
      ProtectClock = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      # PrivateMounts = true;
      RestrictSUIDSGID = true;
      ProtectHostname = true;
      LockPersonality = true;
      ProtectKernelTunables = true;
      ProtectSystem = "strict";
      ProtectProc = "invisible";
      ProtectHome = true;
      # PrivateNetwork = true;
      PrivateUsers = true;
      PrivateTmp = true;
      UMask = "0077";
      # RestrictAddressFamilies = [ "AF_UNIX AF_INET AF_INET6" ];
      SystemCallArchitectures = "native";
    };
  };

  environment.systemPackages = [ config.services.postgresql.package ];
}
