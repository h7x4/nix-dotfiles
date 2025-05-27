{ config, pkgs, lib, ... }:
let
  cfg = config.programs.newsboat;
  package = pkgs.newsboat;
in
{
  options.programs.newsboat.fetch-articles = {
    enable = lib.mkEnableOption "automatic article fetcher for newsboat";

    onCalendar = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      example = "weekly";
      # TODO: link to systemd manpage for format.
      description = "How often to fetch new articles.";
    };
  };

  config = lib.mkIf cfg.fetch-articles.enable {
    # TODO: wait for internet
    systemd.user.services.newsboat-fetch-articles = {
      Unit = {
        Description = "Automatically fetch new articles for newsboat";
        Documentation = [ "man:newsboat(1)" ];
      };

      Service = {
        Type = "oneshot";
        Slice = "background.slice";
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        ExecStart = "${lib.getExe pkgs.flock} %t/newsboat.lock ${lib.getExe package} --execute=reload";
      };
    };

    systemd.user.timers.newsboat-fetch-articles = {
      Unit = {
        Description = "Automatically fetch new articles for newsboat";
        Documentation = [ "man:newsboat(1)" ];
        After = [ "network.target" ];
      };

      Timer = {
        Unit = "newsboat-fetch-articles.service";
        OnCalendar = cfg.fetch-articles.onCalendar;
        Persistent = true;
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
