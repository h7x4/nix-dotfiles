{ pkgs, lib, config, secrets, inputs, ... }:
{
  sops.secrets."cloudflare/api-key" = {};

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "h7x4@nani.wtf";
      dnsProvider = "cloudflare";
      credentialsFile = config.sops.secrets."cloudflare/api-key".path;
      dnsPropagationCheck = true;
    };
    certs."nani.wtf" = {
      extraDomainNames = [ "*.nani.wtf" ];
    };
  };

  users.groups.${config.security.acme.certs."nani.wtf".group}.members = [ "nginx" ];

  services.nginx = let
    generateServerAliases =
      domains: subdomains:
      lib.lists.flatten (map (s: map (d: "${s}.${d}") domains) subdomains);

    s = toString;
  in {
    enable = true;
    enableReload = true;

    statusPage = true;

    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;

    upstreams = let
      inherit (secrets) ips ports;
      srv = config.services;
      sa = config.local.socketActivation;
    in {
      "atuin".servers."unix:${sa.atuin.newSocketAddress}" = { };
      "dynmap".servers."localhost:${s ports.minecraft.dynmap}" = { };
      "gitea".servers."unix:/run/gitea/gitea.sock" = { };
      "grafana".servers."unix:/run/grafana/grafana.sock" = { };
      "headscale".servers."localhost:${s srv.headscale.port}" = { };
      "hedgedoc".servers."unix:${srv.hedgedoc.settings.path}" = { };
      "hydra".servers."localhost:${s srv.hydra.port}" = { };
      "idrac".servers."${ips.idrac}" = { };
      "invidious".servers."unix:${sa.invidious.newSocketAddress}" = { };
      "jupyter".servers."unix:${sa.jupyter.newSocketAddress}" = { };
      "kanidm".servers."localhost:8300" = { };
      "navidrome".servers."unix:${sa.navidrome.newSocketAddress}" = { };
      "osuchan".servers."localhost:${s ports.osuchan}" = { };
      "pgadmin".servers."unix:${srv.uwsgi.instance.vassals.pgadmin.socket}" = { };
      "plex".servers."localhost:${s ports.plex}" = { };
      "vaultwarden".servers."unix:${sa.vaultwarden.newSocketAddress}" = { };
    };

    virtualHosts = let
      inherit (lib.attrsets) nameValuePair listToAttrs recursiveUpdate;
      inherit (lib.lists) head drop;
      inherit (secrets) domains keys;

      cloudflare-origin-pull-ca = builtins.fetchurl {
        url = "https://developers.cloudflare.com/ssl/static/authenticated_origin_pull_ca.pem";
        sha256 = "0hxqszqfzsbmgksfm6k0gp0hsx9k1gqx24gakxqv0391wl6fsky1";
      };

      host =
        subdomains: extraSettings: let
          settings = with keys.certificates; {
            serverAliases = drop 1 (generateServerAliases domains subdomains);
            useACMEHost = "nani.wtf";
            forceSSL = true;
            kTLS = true;

            extraConfig = ''
              ssl_client_certificate ${cloudflare-origin-pull-ca};
              ssl_verify_client on;
            '';
          };
        in
          nameValuePair "${head subdomains}.${head domains}" (recursiveUpdate settings extraSettings);

      proxy =
        subdomains: url: extraSettings:
        host subdomains (recursiveUpdate { locations."/".proxyPass = url; } extraSettings);

      enableWebsockets = { locations."/".proxyWebsockets = true; };
    in (listToAttrs ([
      {
        name = "nani.wtf";
        value = {
          locations = {
            "= /".return = "301 https://www.nani.wtf/";
            "/.well-known/".alias = "${./well-known}/";
            "/.well-known/openpgpkey/hu/" = {
              alias = "${./well-known/openpgpkey/hu}/";
              extraConfig = ''
                default_type application/octet-stream;
              '';
            };
          };

          useACMEHost = "nani.wtf";
          forceSSL = true;

          extraConfig = ''
            add_header Access-Control-Allow-Origin *;
            default_type text/plain;
            ssl_client_certificate ${cloudflare-origin-pull-ca};
            ssl_verify_client on;
          '';
        };
      }
      # (host ["www"] { root = "${inputs.website.packages.${pkgs.system}.default}/"; })
      (host ["www"] {
        locations."/" = {
          tryFiles = "$uri /index.html";
          root = pkgs.writeTextDir "index.html" (lib.fileContents ./temp-website.html);
        };
      })
      (host ["pg"] {
        locations."/" = {
        extraConfig = ''
          include ${pkgs.nginx}/conf/uwsgi_params;
          uwsgi_pass pgadmin;
        '';
        };
      })
      # (proxy ["pg"] "http://localhost:${s ports.pgadmin}" {
      #   extraConfig = ''
      #     proxy_set_header X-CSRF-Token $http_x_pga_csrftoken;
      #   '';
      # })
      # (proxy ["matrix"] "http://localhost:${s ports.matrix.listener}" {})
      (host ["matrix"] {
        enableACME = lib.mkForce false;
        locations."/_synapse".proxyPass = "http://$synapse_backend";
      })
      (host ["madmin"] { root = "${pkgs.synapse-admin}/"; })
      # This one gets properly configured by the nextcloud module itself.
      # It just needs the cloudflare and SSL settings.
      (host ["cloud"] {})
      # (host ["cache"] { root = "/var/lib/nix-cache"; })
      # (proxy ["slack-bot"] "http://localhost:9898" {})
      (proxy ["atuin"] "http://atuin" {})
      (proxy ["auth"] "https://kanidm" { extraConfig = "proxy_ssl_verify off;"; })
      (proxy ["bw"] "http://vaultwarden" {})
      (proxy ["docs"] "http://hedgedoc" {})
      (proxy ["git"] "http://gitea" {})
      (proxy ["hydra"] "http://hydra" {})
      (proxy ["idrac"] "https://idrac" {})
      (proxy ["log"] "http://grafana" enableWebsockets)
      (proxy ["map"] "http://dynmap" {})
      (proxy ["osu"] "http://osuchan" {})
      (proxy ["plex"] "http://plex" {})
      (proxy ["mus"] "http://navidrome" enableWebsockets)
      (proxy ["py"] "http://jupyter" enableWebsockets)
      (proxy ["vpn"] "http://headscale" enableWebsockets)
      (proxy ["yt"] "http://invidious" {})

      (host ["h7x4-stickers"] {})
      (host ["pingu-stickers"] {})
    ]));

    streamConfig = ''
      server {
        listen 0.0.0.0:53589;
        listen [::0]:53589;
        proxy_pass localhost:${s config.services.taskserver.listenPort};
      }
    '';
  };

  # NOTE: This is needed for nginx to be able
  #       to connect to sockets in /run
  systemd.services.nginx.serviceConfig.ProtectHome = false;

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
