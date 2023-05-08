{ config, pkgs, lib, secrets, ... }: {

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      local hydra all ident map=hydra-users
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
    port = secrets.ports.postgres;
    dataDir = "${config.machineVars.dataDrives.drives.postgres}/${config.services.postgresql.package.psqlSchema}";
    # settings = {};
  };

  services.postgresqlBackup = {
    enable = true;
    location = "${config.machineVars.dataDrives.drives.backup}/postgres";
    backupAll = true;
  };

  environment.systemPackages = [ config.services.postgresql.package ];
}
