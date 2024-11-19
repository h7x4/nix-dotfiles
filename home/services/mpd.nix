{ config, pkgs, lib, ... }:
let
  cfg = config.services.mpd;
in
{
  services.mpd = {
    enable = true;
    musicDirectory = config.xdg.userDirs.music;
    playlistDirectory = "${cfg.musicDirectory}/playlists/MPD";
    network.startWhenNeeded = true;

    extraConfig = ''
      pid_file "/run/user/${toString config.home.uid}/mpd/pid"

      zeroconf_enabled "no"

      replaygain "auto"

      restore_paused "yes"

      auto_update "no"

      audio_output {
        type "pipewire"
        name "PipeWire Sound Server"
      }

      audio_output {
        type "fifo"
        name "Visualizer feed"
        path "/run/user/${toString config.home.uid}/mpd/visualizer.fifo"
        format "44100:16:2"
      }

      resampler {
        plugin "soxr"
        quality "very high"
      }

      playlist_plugin {
        name "cue"
        enabled "true"
      }

      playlist_plugin {
        name "m3u"
        enabled "true"
      }

      playlist_plugin {
        name "extm3u"
        enabled "true"
      }

      playlist_plugin {
        name "flac"
        enabled "true"
      }

      playlist_plugin {
        name "rss"
        enabled "true"
      }
    '';
  };

  # TODO: upstream unix socket support to home-manager

  systemd.user.services.mpd = {
    Unit = {
      Documentation = [
        "man:mpd(1)"
        "man:mpd.conf(5)"
      ];
    };
    Service = {
      WatchdogSec = 120;

      # for io_uring
      LimitMEMLOCK = "64M";

      # allow MPD to use real-time priority 40
      LimitRTPRIO = 40;
      LimitRTTIME = "infinity";

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

  systemd.user.paths.mpd-update-library = {
    Unit = {
      Description = "Watchdog that updates the mpd library whenever the files are modified";
      Documentation = [
        "man:mpd(1)"
        "man:mpd.conf(5)"
      ];
      WantedBy = [ "paths.target" ];
    };
    Path = {
      PathChanged = cfg.musicDirectory;
      Unit = "mpd-update-library.service";
      TriggerLimitIntervalSec = "1s";
      TriggerLimitBurst = "1";
    };
  };

  systemd.user.services.mpd-update-library = {
    Unit = {
      Description = "Watchdog that updates the mpd library whenever the files are modified";
      Documentation = [
        "man:mpd(1)"
        "man:mpd.conf(5)"
      ];
    };
    Service = {
      Type = "oneshot";
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
}

