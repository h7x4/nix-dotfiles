{ config, lib, ... }:
{
  services.thermald.enable = true;

    systemd.services.thermald = lib.mkIf config.services.thermald.enable {
    documentation = [ "man:thermald(8)" "man:thermal-conf.xml(5)" ];
    unitConfig.ConditionVirtualization = "no";

    serviceConfig = {
      PrivateUsers = true;
      PrivateNetwork = true;

      # AmbientCapabilities = [ "" ];
      # CapabilityBoundingSet = [ "" ];
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      # PrivateDevices = true;
      PrivateMounts = true;
      PrivateTmp = "yes";
      ProcSubset = "pid";
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true; #?
      ProtectProc = "invisible"; #?
      ProtectSystem = "strict";
      RemoveIPC = true;
      UMask = "0777";
      RestrictNamespaces = true;
      # RestrictRealtime = true; #?
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SocketBindDeny = [ "any" ];
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
        "~@resources"
      ];
    };
  };
}

