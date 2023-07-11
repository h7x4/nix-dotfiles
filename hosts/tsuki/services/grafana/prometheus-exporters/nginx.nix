{ config, ... }: let
  cfg = config.services.prometheus;
in {
  services.prometheus = {
    scrapeConfigs = [{
      job_name = "nginx";
      scrape_interval = "15s";
      static_configs = [{
        targets = [ "${cfg.exporters.nginx.listenAddress}:${toString cfg.exporters.nginx.port}" ];
      }];
    }];

    exporters.nginx = {
      enable = true;
      listenAddress = "127.0.0.1";
    };
  };
}
