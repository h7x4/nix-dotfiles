{ config, pkgs, lib, ... }: let
  cfg = config.services.vaultwarden;
in {
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
      INVITATIONS_ALLOWED = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";
      ROCKET_WORKERS = 1;
    };
  };

  systemd.services.vaultwarden = lib.mkIf cfg.enable {
    requires = [ "postgresql.service" ];
  };

  services.postgresql = lib.mkIf cfg.enable {
    enable = true;
    ensureDatabases = [ "vaultwarden" ];
    ensureUsers = [{
      name = "vaultwarden";
      ensureDBOwnership = true;
    }];
  };

  local.socketActivation.vaultwarden = {
    enable = cfg.enable;
    originalSocketAddress = "${cfg.config.ROCKET_ADDRESS}:${toString cfg.config.ROCKET_PORT}";
    newSocketAddress = "/run/vaultwarden.sock";
    privateNamespace = false;
  };
}
