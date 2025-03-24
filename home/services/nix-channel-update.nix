{ config, lib, ... }:
{
  # TODO: make these units run per channel
  systemd.user.timers.update-nix-channels = {
    Unit = {
      Description = "Update nix channels";
    };

    Timer = {
      Unit = "update-nix-channels.service";
      OnCalendar = "daily";
      Persistent = true;
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  systemd.user.services.update-nix-channels = {
    Unit = {
      Description = "Update nix channels";
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${config.nix.package}/bin/nix-channel --update --verbose";
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
    };
  };
}
