{ pkgs, lib, ... }:
{
  systemd.user.services.update-tldr-db = {
    Unit = {
      Description = "Update tealdeer database";
    };

    Service = {
      Type = "oneshot";
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      ExecStart = "${lib.getExe pkgs.tealdeer} --update";
    };
  };

  systemd.user.timers.update-tldr-db = {
    Unit = {
      Description = "Update tealdeer database";
    };

    Timer = {
      Unit = "update-tldr-db.service";
      OnCalendar = "daily";
      Persistent = true;
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
