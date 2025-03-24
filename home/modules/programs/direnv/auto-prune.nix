{ config, pkgs, lib, ... }:
let
  cfg = config.programs.direnv;
in
{
  options.programs.direnv.auto-prune-allowed-dirs = {
    enable = lib.mkEnableOption "automatic pruning of direnv dirs";

    onCalendar = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      example = "weekly";
      # TODO: link to systemd manpage for format.
      description = "How often to prune dirs.";
    };
  };

  config = lib.mkIf cfg.auto-prune-allowed-dirs.enable {
    systemd.user.services.direnv-auto-prune-allowed-dirs = {
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

    systemd.user.timers.direnv-auto-prune-allowed-dirs = {
      Unit = {
        Description = "Prune unused allowed directories for direnv";
        Documentation = [ "man:direnv(1)" ];
      };

      Timer = {
        Unit = "direnv-auto-prune-allowed-dirs.service";
        OnCalendar = cfg.auto-prune-allowed-dirs.onCalendar;
        Persistent = true;
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
