{ pkgs, config, secrets, inputs, ... }:
  let
    # TODO: fix lib
    lib = pkgs.lib;
      
    inherit (secrets) ips ports;
  in
{

  # All of these nginx endpoints are hosted through a cloudflare proxy.
  # This has several implications for the configuration:
  #   - The sites I want to protect using a client side certificate needs to 
  #     use a client side certificate given by cloudflare, since the client cert set here
  #     only works to secure communication between nginx and cloudflare
  #   - I don't need to redirect http traffic to https manually, as cloudflare does it for me
  #   - I don't need to request ACME certificates manually, as cloudflare does it for me.

  services.nginx = let
    generateServerAliases =
      domains: subdomains:
      lib.lists.flatten (map (s: map (d: "${s}.${d}") domains) subdomains);
    
    s = toString;
  in {
    enable = true;
    enableReload = true;
    
    statusPage = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

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
            onlySSL = true;
            sslCertificate = server.crt;
            sslCertificateKey = server.key;

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

    in (listToAttrs [
      {
        name = "nani.wtf";
        value = {
          locations."/test".root = pkgs.writeText "asdf.txt" "hello";
          locations."/.well-known/matrix/server".extraConfig = ''
            return 200 '{"m.server": "matrix.nani.wtf:443"}';
            default_type application/json;
            add_header Access-Control-Allow-Origin *;
          '';
          onlySSL = true;

          sslCertificate = keys.certificates.server.crt;
          sslCertificateKey = keys.certificates.server.key;

            extraConfig = ''
              ssl_client_certificate ${cloudflare-origin-pull-ca};
              ssl_verify_client on;
            '';
        };
      }
      (proxy ["plex"] "http://localhost:${s ports.plex}" {})
      (host ["www"] { root = "${inputs.website.defaultPackage.${pkgs.system}}/"; })
      (proxy ["matrix"] "http://localhost:${s ports.matrix.listener}" {})
      (host ["madmin"] { root = "${pkgs.synapse-admin}/"; })
      (host ["cache"] { root = "/var/lib/nix-cache"; })
      (proxy ["git"] "http://localhost:${s ports.gitea}" {})
      (proxy ["px1"] "https://${ips.px1}:${s ports.proxmox}" {
          locations."/".proxyWebsockets = true;
      })
      (proxy ["idrac"] "https://${ips.idrac}" {})
      (proxy ["searx"] "http://localhost:${s ports.searx}" {})
      (proxy ["dyn"] "http://${ips.crafty}:${s ports.dynmap}" {
        # basicAuthFile = keys.htpasswds.default;
      })
      (proxy ["log"] "http://localhost:${s ports.grafana}" {
        locations."/".proxyWebsockets = true;
      })
      (proxy ["pg"] "http://localhost:${s ports.pgadmin}" {})
      # (host ["vpn"] "" {})
      (proxy ["hydra"] "http://localhost:${s ports.hydra}" {})
      (proxy ["air"] "https://${ips.kansei}:${s ports.kansei}" {})

      # (proxy ["sync" "drive"] "" {})
      # (proxy ["music" "mpd"] "" {})
    ]) // {
      # Disabled for time being
      # ${config.services.jitsi-meet.hostName} = {
        # enableACME = true;
        # forceSSL = true;
      # };
    };

    upstreams = {};

    streamConfig = ''
      upstream minecraft {
        server ${ips.crafty}:${s ports.minecraft};
      }

      server {
        listen 0.0.0.0:${s ports.minecraft};
        listen [::0]:${s ports.minecraft};
        proxy_pass minecraft;
      }
    '';
      # upstream openvpn {
      #   server localhost:${s ports.openvpn};
      # }

      # server {
      #   listen 0.0.0.0:${s ports.openvpn};
      #   listen [::0]:${s ports.openvpn};
      #   proxy_pass openvpn;
      # }
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  #   secrets.ports.openvpn
    ports.minecraft
  ];
}
