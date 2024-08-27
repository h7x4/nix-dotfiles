{ ... }:
{
  # source: https://github.com/logrotate/logrotate/blob/main/examples/logrotate.service
  systemd.services.logrotate = {
    documentation = [ "man:logrotate(8)" "man:logrotate.conf(5)" ];
    unitConfig.RequiresMountsFor = "/var/log";
    serviceConfig = {
      Nice = 19;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;

      ReadWritePaths = [ "/var/log" ];

      AmbientCapabilities = [ "" ];
      CapabilityBoundingSet = [ "" ];
      DeviceAllow = [ "" ];
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true; # disable for third party rotate scripts
      PrivateDevices = true;
      PrivateNetwork = true; # disable for mail delivery
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true; # disable for userdir logs
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "full";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true; # disable for creating setgid directories
      SocketBindDeny = [ "any" ];
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
      ];
    };
  };
}
