{ config, pkgs, lib, ... }:
let
  cfg = config.programs.direnv;
in
{
  config = {
    systemd.user.services.prune-allowed-direnv-dirs = {
      Unit = {
        Description = "Prune unused allowed directories for direnv";
        Documentation = [ "man:direnv(1)" ];
        ConditionPathExists = "${config.xdg.dataHome}/direnv/allow";
      };

      Service = {
        Type = "oneshot";
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        ExecStart = "${lib.getExe cfg.package} prune";
      };
    };

    systemd.user.timers.prune-allowed-direnv-dirs = {
      Unit = {
        Description = "Prune unused allowed directories for direnv";
        Documentation = [ "man:direnv(1)" ];
      };

      Timer = {
        Unit = "prune-allowed-direnv-dirs.service";
        OnCalendar = "daily";
        Persistent = true;
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
