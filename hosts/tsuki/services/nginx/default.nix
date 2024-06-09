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
      "grafana".servers."unix:/run/grafana/grafana.sock" = { };
      "headscale".servers."localhost:${s srv.headscale.port}" = { };
      "hedgedoc".servers."unix:${srv.hedgedoc.settings.path}" = { };
      "idrac".servers."${ips.idrac}" = { };
      "kanidm".servers."localhost:8300" = { };
      "osuchan".servers."localhost:${s ports.osuchan}" = { };
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

      # nonCFHost =
      #   subdomains: extraSettings: let
      #     settings = with keys.certificates; {
      #       useACMEHost = "nani.wtf";
      #       forceSSL = true;
      #       kTLS = true;
      #     };
      #   in
      #     nameValuePair "${head subdomains}.${head domains}" (recursiveUpdate settings extraSettings);

      # nonCFProxy =
      #   subdomains: url: extraSettings:
      #   nonCFHost subdomains (recursiveUpdate { locations."/".proxyPass = url; } extraSettings);

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
      (host ["testmap"] {
        root = "/var/lib/mcmap";
        locations = {
          "~* ^/maps/[^/]*/tiles/[^/]*.json$".extraConfig = ''
            error_page 404 =200 /assets/emptyTile.json;
            gzip_static always;
          '';
          "~* ^/maps/[^/]*/tiles/[^/]*.png$".tryFiles = "$uri =204";
        };
      })
      (host ["www"] {
        locations."/" = {
          tryFiles = "$uri /index.html";
          root = pkgs.writeTextDir "index.html" (lib.fileContents ./temp-website.html);
        };
      })
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
      (host ["git"] {
        locations."/".extraConfig = ''
          location /h7x4 {
            location ~ /h7x4/(?<project>[a-zA-Z0-9\./_-]*) {
              return 301 $scheme://git.pvv.ntnu.no/oysteikt/$project;
            }
            return 301 $scheme://git.pvv.ntnu.no/oysteikt/;
          }
          location ~ /[Ss]chool[Ww]ork {
            location ~ /[Ss]chool[Ww]ork/(?<project>[a-zA-Z0-9\./_-]*) {
              return 301 $scheme://git.pvv.ntnu.no/oysteikt-skolearbeid/$project;
            }
            return 301 $scheme://git.pvv.ntnu.no/oysteikt-skolearbeid/;
          }
          return 301 $scheme://git.pvv.ntnu.no$request_uri;
        '';
      })
      (proxy ["idrac"] "https://idrac" {})
      (proxy ["log"] "http://grafana" enableWebsockets)
      (proxy ["map"] "http://dynmap" {})
      (proxy ["osu"] "http://osuchan" {})
      (proxy ["plex"] "http://plex" {})
      # (proxy ["vpn"] "http://headscale" {
      #   locations."/" = {
      #     proxyWebsockets = true;
      #     extraConfig = ''
      #       add_header Access-Control-Allow-Origin *;
      #       add_header Access-Control-Allow-Methods GET,HEAD,POST,OPTIONS;
      #       add_header Access-Control-Max-Age 86400;
      #     '';
      #   };
      # })

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
