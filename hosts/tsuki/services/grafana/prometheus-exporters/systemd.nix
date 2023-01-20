{ ... }:
{
  services.prometheus = {
    scrapeConfigs = [{
      job_name = "systemd";
      scrape_interval = "15s";
      static_configs = [{
        targets = [ "localhost:10395" ];
      }];
    }];

    exporters.systemd = {
      enable = true;
      port = 10395;
      extraFlags = [
        "--systemd.collector.enable-restart-count"
        "--systemd.collector.enable-ip-accounting"
      ];
    };
  };
}
