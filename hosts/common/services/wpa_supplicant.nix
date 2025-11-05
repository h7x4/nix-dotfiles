{ config, lib, ... }:
let
  cfg = config.networking.wireless;
in
{
  systemd.services.wpa_supplicant.serviceConfig = lib.mkIf (cfg.enable || config.networking.hostName == "xps16") {
    RuntimeDirectory = [
      "wpa_supplicant"
      "wpa_supplicant/root-mnt"
    ];
    RootDirectory = "/run/wpa_supplicant/root-mnt";
    BindPaths = [
      "/etc"
      "/run/dbus/system_bus_socket"
      "/tmp"
    ];
    BindReadOnlyPaths = [
      # "/bin/sh"
      builtins.storeDir
    ];

    # wpa_ctrl puts sockets in /tmp
    PrivateTmp = false;
    # PrivateTmp = lib.mkIf (configIsGenerated && !cfg.allowAuxiliaryImperativeNetworks) "disconnected";

    CapabilityBoundingSet = [
      "CAP_NET_ADMIN"
      "CAP_BLOCK_SUSPEND"
      "CAP_NET_RAW"
      "CAP_CHOWN"
    ];
    RestrictNamespaces = true;
    SystemCallFilter = [
      "@system-service"
      "~@resources"
      "@chown"
    ];
    ProtectProc = "invisible";
    SystemCallArchitectures = "native";
    DeviceAllow = "/dev/rfkill";
    DevicePolicy = "closed";
    NoNewPrivileges = true;
    ProtectKernelLogs = true;
    ProtectControlGroups = true;
    ProtectKernelModules = true;
    ProtectSystem = true;
    ProtectHome = true;
    MemoryDenyWriteExecute = true;
    ProtectHostname = true;
    LockPersonality = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    RestrictAddressFamilies = [
      "AF_INET"
      "AF_INET6"
      "AF_NETLINK"
      "AF_PACKET"
      # "AF_ALG" # Used for 'linux' TLS backend
    ] ++ lib.optionals cfg.dbusControlled [
      "AF_UNIX"
    ];
  };
}
