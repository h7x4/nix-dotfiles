{ config, lib, pkgs, ... }:
let
  cfg = config.services.mpd;
  runtimeDir = "/run/user/${toString config.home.uid}/mpd";
in
lib.mkIf cfg.enable {
  services.mpd = {
    musicDirectory = config.xdg.userDirs.music;
    playlistDirectory = "${cfg.musicDirectory}/playlists/MPD";
    network.startWhenNeeded = true;

    autoUpdateDatabase = true;

    extraConfig = ''
      pid_file "${runtimeDir}/pid"

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
        path "${runtimeDir}/visualizer.fifo"
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
      RuntimeDirectory = "mpd";
    };
  };

  systemd.user.tmpfiles.settings."10-mpd".${cfg.dataDir}."d" = {
    user = config.home.username;
  };
}

