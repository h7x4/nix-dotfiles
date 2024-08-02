{ config, ... }:
{
  services.mpd = rec {
    enable = true;
    musicDirectory = config.xdg.userDirs.music;
    playlistDirectory = "${musicDirectory}/playlists/MPD";
    network.startWhenNeeded = true;

    # TODO: make the path specific to the user unit
    extraConfig = ''
      audio_output {
        type "fifo"
        name "Visualizer feed"
        path "/tmp/mpd.fifo"
        format "44100:16:2"
      }

      audio_output {
        type "pipewire"
        name "PipeWire Sound Server"
      }
    '';
  };

  # TODO: disable auto_update and use systemd path to listen for changes
  # TODO: upstream unix socket support to home-manager
}

