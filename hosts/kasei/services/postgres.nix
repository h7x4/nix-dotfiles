{ pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    package = pkgs.postgresql_17;
    authentication = ''
      # tailscale xps
      host all all 100.94.170.21/32 md5
    '';
  };

  networking.firewall.allowedTCPPorts = [ 5432 ];
}
