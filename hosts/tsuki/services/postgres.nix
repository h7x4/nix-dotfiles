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
    dataDir = "${config.machineVars.dataDrives.default}/db/postgres/${config.services.postgresql.package.psqlSchema}";
    # settings = {};
  };

  services.pgadmin = {
    enable = true;
    openFirewall = true;
    initialEmail = "h7x4@nani.wtf";
    initialPasswordFile = "${config.machineVars.dataDrives.default}/var/pgadmin_pass";
    port = secrets.ports.pgadmin;
    settings = {
      DATA_DIR = "${config.machineVars.dataDrives.default}/var/pgadmin";
    };
  };

  services.postgresqlBackup = {
    enable = true;
    location = "${config.machineVars.dataDrives.default}/backup/postgres";
    backupAll = true;
  };
}
