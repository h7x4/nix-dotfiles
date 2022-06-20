{ config, pkgs, lib, secrets, ... }: {

  services.postgresql = {
    enable = true;
    # port = secrets.ports.postgres
    # dataDir = 
    # settings = {};
  };

  services.pgadmin = {
    enable = true;
    openFirewall = true;
    # port = secrets.ports.pgadmin
    # settings = {
    # };
  };
}
