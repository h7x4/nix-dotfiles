{ config, ... }:
{
  services.mpd = rec {
    enable = true;
    musicDirectory = config.xdg.userDirs.music;
    playlistDirectory = "${musicDirectory}/playlists/MPD";
  };
}

