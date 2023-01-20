{ ... }:
{
  services.prometheus = {
    scrapeConfigs = [{
      job_name = "redis";
      scrape_interval = "15s";
      static_configs = [{
        targets = [ "localhost:10394" ];
      }];
    }];

    exporters.redis = {
      enable = true;
      port = 10394;
    };
  };
}
