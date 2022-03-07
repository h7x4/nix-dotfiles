{ pkgs }:
{
  services.deluge = {
    enable = true;
    user = "h7x4";

    # https://git.deluge-torrent.org/deluge/tree/deluge/core/preferencesmanager.py#n41
    # config = {
    #   download_location = "";
    #   share_ratio_limit = "";
    #   daemon_port = "";
    #   listen_ports = "";
    # };

    openFirewall = true;
    # authFile = 

    declarative = true;

    web = {
      enable = true;
      # port = 
      openFirewall = true;
    };
  };
}
