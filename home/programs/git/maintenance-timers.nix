{ config, pkgs, lib, ... }:
let
  cfg = config.programs.git;
in
{
  systemd.user.services."git-maintenance@" = {
    Unit = {
      Description = "Optimize Git repositories data";
      Documentation = [ "man:git-maintenance(1)" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${lib.getExe pkgs.git} for-each-repo --config=maintenance.repo maintenance run --no-quiet --schedule=%i";

      Environment = [
        "PATH=${lib.makeBinPath (with pkgs; [ cfg.package openssh ])}"
      ];

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

  systemd.user.timers."git-maintenance@" = {
    Unit = {
      Description = "Optimize Git repositories data";
      Documentation = [ "man:git-maintenance(1)" ];
    };

    Timer = {
      Persistent = true;
      OnCalendar = "%i";
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  systemd.user.timers."git-maintenance@hourly".Timer.OnCalendar = "*-*-* 1..23:05:00";
  systemd.user.timers."git-maintenance@daily".Timer.OnCalendar = "Tue..Sun *-*-* 0:05:00";
  systemd.user.timers."git-maintenance@weekly".Timer.OnCalendar = "Mon 0:05:00";
}
