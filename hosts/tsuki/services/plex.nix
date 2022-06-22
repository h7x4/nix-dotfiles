{ config, secrets, ... }:
{
  services.plex = {
    enable = true;
    openFirewall = true;
    dataDir = "${config.machineVars.dataDrives.default}/var/plex";
  };

  # networking.firewall.allowedTCPPorts = [ secrets.ports.plex ];
}
