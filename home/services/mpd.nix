{ config, ... }:
{
  services.mpd = rec {
    enable = true;
    musicDirectory = "${config.services.dropbox.path}/music/music";
    # musicDirectory = "${config.home.homeDirectory}/music";
    playlistDirectory = "${musicDirectory}/playlists/MPD";
  };
}

