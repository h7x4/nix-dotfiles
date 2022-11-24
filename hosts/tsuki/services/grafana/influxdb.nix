{ config, secrets, ... }:
{
  # services.influxdb = {
  #   enable = true;
  #   dataDir = "${config.machineVars.dataDrives.default}/var/influxdb";
  #   extraConfig = {
  #     udp = {
  #       enabled = true;
  #       bind-address = "0.0.0.0:8089";
  #       database = "proxmox";
  #       batch-size = 1000;
  #       batch-timeout = "1s";
  #     };
  #   };
  # };
}
