{ pkgs, config, ... }:
{
  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    # TODO: Set a database password
    environmentFile = pkgs.writeText "vaultwarden.env" ''
      DATABASE_URL=postgresql://vaultwarden:@%2Fvar%2Frun%2Fpostgresql/vaultwarden
    '';
    config = {
      DOMAIN = "https://bw.nani.wtf";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";
      ROCKET_WORKERS = 1;
    };
  };

  systemd.services.vaultwarden = {
    requires = [ "postgresql.service" ];
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "vaultwarden" ];
    ensureUsers = [
      (rec {
        name = "vaultwarden";
        ensurePermissions = {
          "DATABASE \"${name}\"" = "ALL PRIVILEGES";
        };
      })
    ];
  };
}
