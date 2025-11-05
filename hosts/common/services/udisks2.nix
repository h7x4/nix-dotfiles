{ config, lib, ... }:
let
  cfg = config.services.udisks2;
in
{
  services.udisks2.enable = true;

  systemd.services.udisks2 = lib.mkIf cfg.enable {
    after = lib.optionals cfg.mountOnMedia [ "systemd-tmpfiles-setup.service" ];
    requires = lib.optionals cfg.mountOnMedia [ "systemd-tmpfiles-setup.service" ];

    serviceConfig = {
      User = "root";
      Group = "root";

      StateDirectory = "udisks2";
      StateDirectoryMode = "0700";
      RuntimeDirectory = "udisks2";
      RuntimeDirectoryMode = "0755";

      # A lot of the omitted Private*/Protect* settings would imply
      # this to be true, which would have the daemon only mount disks
      # inside its own sandbox and so breaking the main functionality.
      PrivateMounts = false;

      CapabilityBoundingSet = [
        "CAP_SYS_ADMIN" # Needed for mount(2) and umount(2)
      ];
      SystemCallFilter = [
        "@system-service"
        "~@privileged @resources"
        "@chown @mount"
      ];
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      ProtectClock = true;
      ProtectHostname = true;
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_NETLINK" # Needed to talk to udev
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      UMask = "022";
    };
  };
}
