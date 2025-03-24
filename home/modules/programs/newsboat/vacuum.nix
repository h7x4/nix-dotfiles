{ config, pkgs, lib, ... }:
let
  cfg = config.programs.newsboat;
  package = pkgs.newsboat;
in
{
  options.programs.newsboat.vacuum = {
    enable = lib.mkEnableOption "automatic cleaning of the newsboat cache";

    onCalendar = lib.mkOption {
      type = lib.types.str;
      default = "weekly";
      example = "monthly";
      # TODO: link to systemd manpage for format.
      description = "How often to run the cleaning.";
    };
  };

  config = lib.mkIf cfg.vacuum.enable {
    systemd.user.services.newsboat-vacuum = {
      Unit = {
        Description = "Automatically clean newsboat cache";
        Documentation = [ "man:newsboat(1)" ];
      };

      Service = {
        Type = "oneshot";
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        ExecStart = "${lib.getExe pkgs.flock} %t/newsboat.lock ${lib.getExe package} --vacuum";
      };
    };

    systemd.user.timers.newsboat-vacuum = {
      Unit = {
        Description = "Automatically clean newsboat cache";
        Documentation = [ "man:newsboat(1)" ];
      };

      Timer = {
        Unit = "newsboat-vacuum.service";
        OnCalendar = cfg.vacuum.onCalendar;
        Persistent = true;
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
