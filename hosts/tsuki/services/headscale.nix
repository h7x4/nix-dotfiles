{ config, pkgs, lib, ... }: let
  cfg = config.services.headscale;
in {
  sops.secrets."headscale/oauth2_secret" = lib.mkIf cfg.enable rec {
    restartUnits = [ "headscale.service" ];
    owner = config.services.headscale.user;
    group = config.users.users.${owner}.group;
  };
  sops.secrets."postgres/headscale" = lib.mkIf cfg.enable rec {
    restartUnits = [ "headscale.service" ];
    owner = config.services.headscale.user;
    group = config.users.users.${owner}.group;
  };

  services.headscale = {
    enable = true;

    port = 39304;

    settings = {
      server_url = "https://vpn.nani.wtf";
      log.level = "info";
      ip_prefixes = [ "100.64.0.0/24" ];

      dns_config = {
        magic_dns = true;
        base_domain = "nani.wtf";
        nameservers = [
          "1.1.1.1"
        ];
      };

      db_type = "postgres";
      db_user = "headscale";
      db_name = "headscale";
      db_host = "/var/run/postgresql";
      db_port = null;
      db_password_file = config.sops.secrets."postgres/headscale".path;

      oidc = {
        issuer = "https://auth.nani.wtf/oauth2/openid/headscale";
        client_id = "headscale";
        client_secret_path = config.sops.secrets."headscale/oauth2_secret".path;
      };
    };
  };

  systemd.services.headscale = lib.mkIf cfg.enable {
    requires = [
      "postgresql.service"
      "kanidm.service"
    ];
  };

  services.postgresql = lib.mkIf cfg.enable {
    enable = true;
    ensureDatabases = [ "headscale" ];
    ensureUsers = [
      (rec {
        name = "headscale";
        ensurePermissions = {
          "DATABASE \"${name}\"" = "ALL PRIVILEGES";
        };
      })
    ];
  };

  environment.systemPackages = lib.mkIf cfg.enable [ pkgs.headscale ];

  services.tailscale.enable = true;

  networking.firewall = {
    checkReversePath = "loose";
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
}
