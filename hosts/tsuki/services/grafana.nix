{ config, lib, secrets, ... }:
{
  services.grafana = {
    enable = true;
    domain = "log.nani.wtf";
    port = secrets.ports.grafana;
    addr = "0.0.0.0";
  };

  # services.influxdb = {
  #   enable = true;
  #   dataDir = "/data/var/influxdb";
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

  services.prometheus = {
    enable = true;
    port = secrets.ports.prometheus;

    scrapeConfigs = [
      {
        job_name = "synapse";
        scrape_interval = "15s";
        metrics_path = "/_synapse/metrics";
        static_configs = [
          {
            targets = [ "localhost:${toString secrets.ports.matrix.listener}" ];
          }
        ];
      }
      {
        job_name = "minecraft";
        # scrape_interval = "15s";
        # metrics_path = "/_synapse/metrics";
        static_configs = [
          {
            targets = [ "${secrets.ips.crafty}:${toString secrets.ports.prometheus-crafty}" ];
            labels = {
              server_name = "my-minecraft-server";
            };
          }
        ];
      }
    ];

    exporters = {
      jitsi.enable = true;
      nginx.enable = true;
      nginxlog.enable = true;
      systemd.enable = true;
      # postgres.enable = true;
    };

    # globalConfig = {

    # };

  };

  # services.loki = {
  #   enable = true;
    # configFile = ./loki-local-config.yaml;
    # config = {

    # };
  # };

}
