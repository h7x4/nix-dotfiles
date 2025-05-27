{ config, pkgs, lib, ... }:
let
  cfg = config.services.mpd;
in
{
  options.services.mpd.autoUpdateDatabase = lib.mkEnableOption "watchdog that updates the mpd database upon file changes";

  config = lib.mkIf cfg.autoUpdateDatabase {
    systemd.user.paths.mpd-update-database = {
      Install.WantedBy = [ "paths.target" ];
      Unit = {
        Description = "Watchdog that updates the mpd database upon file changes";
        Documentation = [
          "man:mpd(1)"
          "man:mpd.conf(5)"
        ];
      };
      Path = {
        PathChanged = [
          cfg.musicDirectory
          cfg.playlistDirectory
        ];
        Unit = "mpd-update-database.service";
        TriggerLimitIntervalSec = "1s";
        TriggerLimitBurst = "1";
      };
    };

    systemd.user.services.mpd-update-database = {
      Unit = {
        Description = "Watchdog that updates the mpd library whenever the files are modified";
        Documentation = [
          "man:mpd(1)"
          "man:mpd.conf(5)"
        ];
      };
      Service = {
        Type = "oneshot";
        Slice = "background.slice";
        ExecStart = "${lib.getExe pkgs.mpc-cli} update --wait";

        PrivateUsers = true;
        ProtectSystem = true;
        NoNewPrivileges = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
      };
    };
  };
}
