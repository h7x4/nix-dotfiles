{ config, pkgs, ... }:
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

  systemd.services.headscale = {
    requires = [
      "postgresql.service"
      "kanidm.service"
    ];
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

  networking.firewall = {
    checkReversePath = "loose";
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
}
