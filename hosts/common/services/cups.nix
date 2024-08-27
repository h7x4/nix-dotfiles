{ config, lib, ... }:
{
  systemd.services = lib.mkIf config.services.printing.enable {
    cups.serviceConfig = {
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectClock= true;
      ProtectControlGroups = true;
      ProtectHostname = true; 
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      PrivateDevices = true;
      NoNewPrivileges = true;
      # User =
      AmbientCapabilities = [ "" ];
      CapabilityBoundingSet = [ "" ];
      DevicePolicy = "closed";
      KeyringMode = "private";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      PrivateUsers = true;
      RemoveIPC = true;
      # RestrictAddressFamilies = [ "" ];
      RestrictNamespaces=true;
      RestrictRealtime=true;
      RestrictSUIDSGID=true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
      ];
      UMask = "0077";
    };
    cups-browsed.serviceConfig = {
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectClock= true;
      ProtectControlGroups = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      PrivateDevices = true;
      NoNewPrivileges = true;
      # User =
      AmbientCapabilities = [ "" ];
      CapabilityBoundingSet = [ "" ];
      DevicePolicy = "closed";
      KeyringMode = "private";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      PrivateUsers = true;
      RemoveIPC = true;
      # RestrictAddressFamilies = [ "" ];
      RestrictNamespaces=true;
      RestrictRealtime=true;
      RestrictSUIDSGID=true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
      ];
      UMask = "0077";
    };
  };
}
