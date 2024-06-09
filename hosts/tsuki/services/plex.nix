{ config, ... }: let 
  cfg = config.services.plex;
in {
  services.plex = {
    enable = true;
    openFirewall = true;
  };
}
