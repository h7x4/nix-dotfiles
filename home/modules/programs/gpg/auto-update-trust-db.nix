{ config, pkgs, lib, ... }:
let
  cfg = config.programs.gpg;
in
{
  options = {
    programs.gpg.auto-update-trust-db = {
      enable = lib.mkEnableOption "a timer that automatically updates your trust db";
      frequency = lib.mkOption {
        default = "daily";
        type = lib.types.str;
        description = ''
          How often to update trust db

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
    systemd.user.services.update-trust-db = lib.mkIf cfg.auto-update-trust-db.enable {
      Unit = {
        Description = "Update gpg trust database";
        Documentation = [ "man:gpg(1)" ];
      };

      Service = {
        Type = "oneshot";
        Slice = "background.slice";
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        ExecStart = "${lib.getExe cfg.package} --update-trustdb";
        Environment = [
          "GNUPGHOME=${cfg.homedir}"
        ];
      };
    };

    systemd.user.timers.gpg-refresh-keys = lib.mkIf cfg.auto-update-trust-db.enable {
      Unit = {
        Description = "Update gpg trust database";
        Documentation = [ "man:gpg(1)" ];
      };

      Timer = {
        Unit = "update-trust-db.service";
        OnCalendar = cfg.auto-update-trust-db.frequency;
        Persistent = true;
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
