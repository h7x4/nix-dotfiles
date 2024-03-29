{ config, ... }: let 
  cfg = config.services.plex;
in {
  services.plex = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.plex.serviceConfig = {
    ReadWritePaths = [ cfg.dataDir ];
    NoNewPrivileges = true;
    PrivateDevices = true;
    ProtectClock = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    PrivateMounts = true;
    RestrictSUIDSGID = true;
    ProtectHostname = true;
    LockPersonality = true;
    ProtectKernelTunables = true;
    ProtectSystem = "strict";
    ProtectProc = true;
    ProtectHome = true;
    # PrivateNetwork = true;
    PrivateUsers = true;
    PrivateTmp = true;
    UMask = "0007";
    # RestrictAddressFamilies = [ "AF_UNIX AF_INET AF_INET6" ];
    SystemCallArchitectures = "native";
  };
}
