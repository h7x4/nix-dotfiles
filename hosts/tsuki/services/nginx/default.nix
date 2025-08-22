{ config, pkgs, lib, inputs, ... }:
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

    package = pkgs.nginxQuic;

    statusPage = true;

    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;

    appendConfig = ''
      pcre_jit on;
      worker_processes auto;
      worker_rlimit_nofile 100000;
    '';
    eventsConfig = ''
      worker_connections 2048;
      use epoll;
      multi_accept on;
    '';

    upstreams = let
      srv = config.services;
      sa = config.local.socketActivation;
    in {
      "atuin".servers."unix:${sa.atuin.newSocketAddress}" = { };
      "dynmap".servers."localhost:8123" = { };
      "grafana".servers."unix:/run/grafana/grafana.sock" = { };
      "headscale".servers."localhost:${s srv.headscale.port}" = { };
      "hedgedoc".servers."unix:${srv.hedgedoc.settings.path}" = { };
      "idrac".servers."10.0.0.201" = { };
      "irc-matrix-bridge-media".servers."localhost:${s srv.matrix-appservice-irc.settings.ircService.mediaProxy.bindPort}" = { };
      "kanidm".servers."localhost:8300" = { };
      "osuchan".servers."localhost:${s srv.osuchan.port}" = { };
      "plex".servers."localhost:32400" = { };
      "vaultwarden".servers."unix:${sa.vaultwarden.newSocketAddress}" = { };
      "wstunnel".servers = let
        inherit (config.services.wstunnel.servers."ws-tsuki".listen) host port;
      in {
        "${host}:${s port}" = { };
      };
    };

    virtualHosts = let
      inherit (lib.attrsets) nameValuePair listToAttrs recursiveUpdate;
      inherit (lib.lists) head drop;
      domains = [ "nani.wtf" ];

      cloudflare-origin-pull-ca = builtins.fetchurl {
        url = "https://developers.cloudflare.com/ssl/static/authenticated_origin_pull_ca.pem";
        sha256 = "0hxqszqfzsbmgksfm6k0gp0hsx9k1gqx24gakxqv0391wl6fsky1";
      };

      # nonCFHost =
      #   subdomains: extraSettings: let
      #     settings = {
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
          settings = {
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
        quic = true;
        locations = {
          "@empty".return = "204";

          "~* ^/maps/[^/]*/tiles/".extraConfig = ''
            error_page 404 = @empty;
            gzip_static always;
          '';
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
      (proxy ["irc-matrix"] "http://irc-matrix-bridge-media" {})
      
      # (host ["madmin"] { root = "${pkgs.synapse-admin}/"; })
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
      (proxy ["plex"] "http://plex" enableWebsockets)
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

      (proxy ["ws"] "http://wstunnel" enableWebsockets)

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

  systemd.services.nginx.serviceConfig = {
    LimitNOFILE = 65536;

    # NOTE: This is needed for nginx to be able
    #       to connect to sockets in /run
    ProtectHome = false;
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
