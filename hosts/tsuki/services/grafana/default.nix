{ config, lib, secrets, ... }:
{
  imports = [
    ./prometheus.nix
    ./influxdb.nix
    ./loki.nix
  ];

  services.grafana = {
    enable = true;
    domain = "log.nani.wtf";
    port = secrets.ports.grafana;
    addr = "0.0.0.0";
    dataDir = "${config.machineVars.dataDrives.default}/var/grafana";

    database = {
      type = "postgres";
      user = "grafana";
      host = "localhost:${toString secrets.ports.postgres}";
    };
  };
}
