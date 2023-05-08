{ pkgs, secrets, config, ... }:
{
  sops.secrets."headscale/oauth2_secret" = rec {
    restartUnits = [ "headscale.service" ];
    owner = config.services.headscale.user;
    group = config.users.users.${owner}.group;
  };
  sops.secrets."postgres/headscale" = rec {
    restartUnits = [ "headscale.service" ];
    owner = config.services.headscale.user;
    group = config.users.users.${owner}.group;
  };

  services.headscale = {
    enable = true;

    # TODO: make PR
    # dataDir = "${config.machineVars.dataDrives.default}/var/headscale";

    port = secrets.ports.headscale;

    settings = {
      server_url = "https://vpn.nani.wtf";
      log.level = "warn";
      ip_prefixes = [ "10.8.0.0/24" ];

      dns_config = {
        magic_dns = true;
        nameservers = [
          "1.1.1.1"
        ];
      };

      db_type = "postgres";
      db_user = "headscale";
      db_name = "headscale";
      db_host = "localhost";
      db_port = secrets.ports.postgres;
      db_password_file = config.sops.secrets."postgres/headscale".path;

      oidc = {
        issuer = "https://auth.nani.wtf/oauth2/openid/headscale";
        client_id = "headscale";
        client_secret_file = config.sops.secrets."headscale/oauth2_secret".path;
        # allowed_domains = [ "nani.wtf" ];
        allowed_groups = [ "headscale_users" ];
      };
    };
  };

  services.postgresql = {
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

  environment.systemPackages = with pkgs; [ headscale ];

  services.tailscale.enable = true;

  networking.firewall.checkReversePath = "loose";
}
