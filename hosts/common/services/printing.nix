{ config, lib, ... }:
let
  cfg = config.services.printing;
in
{
  # services.printing.enable = !config.machineVars.headless;
  services.printing.enable = false;

  systemd.services = lib.mkIf cfg.enable {
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
    cups-browsed.serviceConfig = lib.mkIf cfg.enable {
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
