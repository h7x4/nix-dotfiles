{ config, pkgs, lib, ... }:
{
  services.avahi = {
    enable = true;
    publish.enable = true;
    publish.addresses = true;
    publish.domain = true;
    publish.hinfo = true;
    publish.userServices = true;
    publish.workstation = true;
    extraServiceFiles.ssh = "${pkgs.avahi}/etc/avahi/services/ssh.service";
  };
}
