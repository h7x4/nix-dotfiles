{ config, pkgs, lib, ... }:
let
  cfg = config.programs.gpg;
in
{
  options = {
    programs.gpg.auto-refresh-keys = {
      enable = lib.mkEnableOption "a timer that automatically refreshes your gpg keys";
      frequency = lib.mkOption {
        default = "daily";
        type = lib.types.str;
        description = ''
          How often to refresh keys.

          :::{.note}
            This value is passed to the systemd
            timer configuration as the onCalendar option.  See
            {manpage}`systemd.time(7)`
            for more information about the format.
          :::
        '';
      };
    };
  };

  config = {
    systemd.user.services.gpg-refresh-keys = lib.mkIf cfg.auto-refresh-keys.enable {
      Unit = {
        Description = "Refresh gpg keys";
        Documentation = [ "man:gpg(1)" ];
      };

      Service = {
        Type = "oneshot";
        Slice = "background.slice";
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        ExecStart = "${lib.getExe cfg.package} --refresh-keys";
        Environment = [
          "GNUPGHOME=${cfg.homedir}"
        ];
      };
    };

    systemd.user.timers.gpg-refresh-keys = lib.mkIf cfg.auto-refresh-keys.enable {
      Unit = {
        Description = "Refresh gpg keys";
        Documentation = [ "man:gpg(1)" ];
      };

      Timer = {
        Unit = "gpg-refresh-keys.service";
        OnCalendar = cfg.auto-refresh-keys.frequency;
        Persistent = true;
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
