{ config, ... }:
{
  services.borgbackup.jobs = let
    createJob = path: endpoint: {
      paths = path;
      encryption.mode = "none";
      environment.BORG_RSH = "ssh -i /home/h7x4/.ssh/id_rsa";
      repo = "ssh://h7x4@10.0.0.220/mnt/SSD1/backup/${endpoint}";
      compression = "auto,zstd";
      startAt = "daily";
    };
  in {
    postgres = createJob config.services.postgresqlBackup.location "postgres";
    minecraft = createJob config.services.minecraft-servers.dataDir "minecraft";
    gitea = createJob config.services.gitea.dump.backupDir "gitea";
  };
}
