{ config, lib, secrets, ... }:
{
  imports = [
    ./prometheus.nix
    ./influxdb.nix
    ./loki.nix
  ];

  services.grafana = {
    enable = true;
    dataDir = "${config.machineVars.dataDrives.default}/var/grafana";

    settings = {
      server = {
        domain = "log.nani.wtf";
        http_addr = "0.0.0.0";
        http_port = secrets.ports.grafana;
      };

      database = {
        type = "postgres";
        user = "grafana";
        host = "localhost:${toString secrets.ports.postgres}";
      };
    };
  };
}
