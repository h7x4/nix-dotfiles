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
        type "pulse"
        name "PulseAudio"
      }
    '';
  };
}

