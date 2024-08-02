{ pkgs, lib, ... }:
{
  programs.tealdeer.enable = true;

  systemd.user.services.tealdeer-refresh = {
    Unit = {
      Description = "Refresh tealdeer contents";
    };

    Service = {
      Type = "oneshot";
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      ExecStart = "${lib.getExe pkgs.tealdeer} --update";
    };
  };

  systemd.user.timers.tealdeer-refresh = {
    Unit = {
      Description = "Refresh tealdeer contents";
    };

    Timer = {
      Unit = "tealdeer-refresh.service";
      OnCalendar = "daily";
      Persistent = true;
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
