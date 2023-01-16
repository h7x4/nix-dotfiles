{ pkgs, secrets, config, ... }:
{
  services.headscale = {
    enable = true;

    # TODO: make PR
    # dataDir = "${config.machineVars.dataDrives.default}/var/headscale";

    serverUrl = "https://vpn.nani.wtf";
    port = secrets.ports.headscale;

    database = {
      type = "postgres";
      user = "headscale";
      name = "headscale";
      host = "localhost";
      port = secrets.ports.postgres;
      passwordFile = "${config.machineVars.dataDrives.default}/keys/postgres/headscale";
    };

    dns = {
      magicDns = true;
      nameservers = [
        "1.1.1.1"
      ];
    };

    settings = {
      log.level = "warn";
      ip_prefixes = [ "10.8.0.0/24" ];
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
