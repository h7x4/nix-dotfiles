{ config, ... }: let
  cfg = config.services.prometheus;
in {
  services.prometheus = {
    scrapeConfigs = [{
      job_name = "php-fpm";
      scrape_interval = "15s";
      static_configs = [{
        targets = [ "${cfg.exporters.php-fpm.listenAddress}:${toString cfg.exporters.nginx.port}" ];
      }];
    }];

    exporters.php-fpm = {
      enable = true;
      listenAddress = "127.0.0.1";
    };
  };
}
