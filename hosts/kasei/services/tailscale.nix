{ config, ... }:
{
  services.tailscale.enable = true;

  networking.firewall = {
    allowedUDPPorts = [ config.services.tailscale.port ];
    checkReversePath = "loose";
    trustedInterfaces = [ "tailscale0" ];
  };
}
