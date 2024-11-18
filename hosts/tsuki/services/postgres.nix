{ config, pkgs, lib, ... }: let
  cfg = config.services.postgresql;
in {
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
    settings = {
      # Source: https://pgtune.leopard.in.ua/
      # DB Version: 15
      # OS Type: linux
      # DB Type: mixed
      # Total Memory (RAM): 12 GB
      # CPUs num: 12
      # Connections num: 150
      # Data Storage: hdd
      
      max_connections = 150;
      shared_buffers = "3GB";
      effective_cache_size = "9GB";
      maintenance_work_mem = "768MB";
      checkpoint_completion_target = 0.9;
      wal_buffers = "16MB";
      default_statistics_target = 100;
      random_page_cost = 4;
      effective_io_concurrency = 2;
      work_mem = "2621kB";
      min_wal_size = "1GB";
      max_wal_size = "4GB";
      max_worker_processes = 12;
      max_parallel_workers_per_gather = 4;
      max_parallel_workers = 12;
      max_parallel_maintenance_workers = 4;
    };
  };

  services.postgresqlBackup = {
    enable = true;
    location = "/data/backup/postgres";
    backupAll = true;
  };

  systemd.services.postgresqlBackup = {
    requires = [ "postgresql.service" ];
  };

  systemd.services.postgresql.serviceConfig.ReadWritePaths = [ cfg.dataDir ];

  environment.systemPackages = [ config.services.postgresql.package ];
}
