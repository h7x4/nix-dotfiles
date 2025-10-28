{ pkgs, ... }:
{
  services.dbus = {
    enable = true;
    implementation = "broker";
    packages = with pkgs; [
      gcr
    ];
  };

  systemd.services.dbus-broker.serviceConfig = {
    LockPersonality = "yes";
    MemoryDenyWriteExecute = "yes";
    NoNewPrivileges = "yes";
    PrivateDevices = "yes";
    ProtectClock = "yes";
    ProtectControlGroups = "yes";
    ProtectHome = "yes";
    ProtectHostname = "yes";
    ProtectKernelLogs = "yes";
    ProtectKernelModules = "yes";
    ProtectKernelTunables = "yes";
    RestrictNamespaces = "yes";
    RestrictRealtime = "yes";
    RestrictSUIDSGID = "yes";
    SystemCallArchitectures = "native";
    UMask = "077";
    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_NETLINK"
    ];
    SystemCallFilter = [
      "@system-service"
      "~@mount"
      "~@resources"
    ];
    AmbientCapabilities = "CAP_AUDIT_WRITE";
    CapabilityBoundingSet = "CAP_AUDIT_WRITE";
  };

  systemd.user.services.dbus-broker.serviceConfig = {
    LockPersonality = "yes";
    MemoryDenyWriteExecute = "yes";
    NoNewPrivileges = "yes";
    PrivateDevices = "yes";
    ProtectClock = "yes";
    ProtectControlGroups = "yes";
    ProtectHome = "yes";
    ProtectHostname = "yes";
    ProtectKernelLogs = "yes";
    ProtectKernelModules = "yes";
    ProtectKernelTunables = "yes";
    RestrictNamespaces = "yes";
    RestrictRealtime = "yes";
    RestrictSUIDSGID = "yes";
    SystemCallArchitectures = "native";
    UMask = "077";
    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_NETLINK"
    ];
    SystemCallFilter = [
      "@system-service"
      "~@resources"
      "~@privileged"
    ];
    AmbientCapabilities = "";
    CapabilityBoundingSet = "";
  };
}
