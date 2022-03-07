{ secrets, ... }:
{
  services.plex = {
    enable = true;
    openFirewall = true;
    dataDir = "/data/var/plex";
  };

  # TODO: make default directories.
  services.samba.shares.plex = {
    path = "/data/media";
    browseable = "yes";
    "read only" = "no";
    "guest ok" = "no";
    "create mode" = 0664;
    "directory mode" = 2775;
    comment = "Movies, Series and other stuff for Plex";
  };

  networking.firewall.allowedTCPPorts = [ secrets.ports.plex ];
}
