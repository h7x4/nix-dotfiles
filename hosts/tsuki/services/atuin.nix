{ config, ... }:
let
  cfg = config.services.atuin;
in
{
  services.atuin = {
    enable = true;
    openRegistration = false;
  };

  systemd.services.atuin = {
    requires = [ "postgresql.service" ];
    serviceConfig = {
      # Hardening
      CapabilityBoundingSet = "";
      LockPersonality = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateMounts = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProcSubset = "pid";
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "full";
      RemoveIPC = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        # Required for connecting to database sockets,
        # and listening to unix socket at `cfg.settings.path`
        "AF_UNIX"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = "~@clock @cpu-emulation @debug @keyring @module @mount @obsolete @raw-io @reboot @setuid @swap @privileged";
      UMask = "0007";
    };
  };

  local.socketActivation.atuin = {
    enable = cfg.enable;
    originalSocketAddress = "${cfg.host}:${toString cfg.port}";
    newSocketAddress = "/run/atuin.sock";
    privateNamespace = false;
  };
}
