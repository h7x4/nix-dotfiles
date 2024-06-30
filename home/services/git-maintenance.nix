{ config, pkgs, lib, ... }:
{
  systemd.user.services."git-maintenance@" = {
    Unit = {
      Description = "Optimize Git repositories data";
      Documentation = [ "man:git-maintenance(1)" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${lib.getExe pkgs.git} for-each-repo --config=maintenance.repo maintenance run --schedule=%i";

      LockPersonality = "yes";
      MemoryDenyWriteExecute = "yes";
      NoNewPrivileges = "yes";
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_VSOCK"
      ];
      RestrictNamespaces = "yes";
      RestrictRealtime = "yes";
      RestrictSUIDSGID = "yes";
      SystemCallArchitectures = "native";
      SystemCallFilter = "@system-service";
    };
  };

  systemd.user.timers."git-maintenance@hourly" = {
    Unit = {
      Description = "Optimize Git repositories data";
      Documentation = [ "man:git-maintenance(1)" ];
    };

    Timer = {
      OnCalendar = "*-*-* 1..23:05:00";
      Persistent = true;
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  systemd.user.timers."git-maintenance@daily" = {
    Unit = {
      Description = "Optimize Git repositories data";
      Documentation = [ "man:git-maintenance(1)" ];
    };

    Timer = {
      OnCalendar = "Tue..Sun *-*-* 0:05:00";
      Persistent = true;
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  systemd.user.timers."git-maintenance@weekly" = {
    Unit = {
      Description = "Optimize Git repositories data";
      Documentation = [ "man:git-maintenance(1)" ];
    };

    Timer = {
      OnCalendar = "Mon 0:05:00";
      Persistent = true;
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
