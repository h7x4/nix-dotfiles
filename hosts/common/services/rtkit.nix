{ config, pkgs, lib, ... }:
let
  cfg = config.security.rtkit;
  package = pkgs.rtkit;
in
{
  systemd.services.rtkit-daemon.serviceConfig = lib.mkIf cfg.enable {
    # Needs to verify the user of the processes.
    PrivateUsers = false;
    # Needs to access other processes to modify their scheduling modes.
    ProcSubset = "all";
    ProtectProc = "default";
    # Canary needs to be realtime.
    RestrictRealtime = false;

    RuntimeDirectory = [ "rtkit/root-mnt" ];
    RootDirectory = "/run/rtkit/root-mnt";
    BindPaths = [ "/run/dbus/system_bus_socket" ];
    BindReadOnlyPaths = [
      builtins.storeDir
      "/etc"
    ];
    NoExecPaths = "/";
    ExecPaths = "${package}/libexec/rtkit-daemon";

    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateTmp = "disconnected";
    ProtectClock = true;
    ProtectControlGroups = "strict";
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectSystem = "strict";
    RemoveIPC = true;
    RestrictAddressFamilies = [ "AF_UNIX" ];
    IPAddressDeny = "any";
    RestrictNamespaces = true;
    RestrictSUIDSGID = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = [
      "@system-service"
      "@mount" # Needs chroot(1)
    ];
    UMask = "0777";
  };
}
