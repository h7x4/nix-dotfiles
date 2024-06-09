{ pkgs, config, secrets, ... }:

# TODO: This kinda sucks, but nextcloud refuses to use the NFS mounted
# drive, as it is not able to lock it properly.
# I'll wait for a while with enabling this service, until I have gotten
# Some proper disks into the server.
{
  sops.secrets."nextcloud/initialPassword" = {
    restartUnits = [ "nextcloud.service" ];
    owner = "nextcloud";
    group = "nextcloud";
  };
  sops.secrets."postgres/nextcloud" = {
    restartUnits = [ "nextcloud.service" ];
    owner = "nextcloud";
    group = "nextcloud";
  };

  services.nextcloud = {
    enable = false;
    hostName = "cloud.nani.wtf";
    https = true;
    maxUploadSize = "10G";
    package = pkgs.nextcloud25;

    datadir = "${config.machineVars.dataDrives.default}/var/nextcloud";

    home = "${config.machineVars.dataDrives.default}/var/nextcloud";

    enableBrokenCiphersForSSE = false;

    caching.redis = true;
    extraOptions = {
      redis = {
        host = config.services.redis.servers.nextcloud.unixSocket;
        port = 0;
        dbindex = 0;
        timeout = 1.5;
      };
    };

    config = {
      defaultPhoneRegion = "NO";

      dbtype = "pgsql";
      dbport = secrets.ports.postgres;
      dbpassFile = config.sops.secrets."postgres/nextcloud".path;

      adminuser = "h7x4";
      adminpassFile = config.sops.secrets."nextcloud/initialPassword".path;
    };
  };

  services.redis.servers.nextcloud = {
    enable = true;
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [{
      name = "nextcloud";
      ensureDBOwnership = true;
    }];
  };
}
