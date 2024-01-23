{ ... }:
{
  services.prometheus = {
    scrapeConfigs = [{
      job_name = "node";
      scrape_interval = "15s";
      static_configs = [{
        targets = [ "localhost:10393" ];
      }];
    }];

    exporters.node = {
      enable = true;
      port = 10393;
      enabledCollectors = [ "systemd" ];
    };
  };

  systemd.services.prometheus-node-exporter.serviceConfig.Slice = "system-prometheus.slice";
}
