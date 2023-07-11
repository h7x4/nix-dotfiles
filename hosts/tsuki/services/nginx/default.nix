{ pkgs, config, secrets, inputs, ... }:
  let
    # TODO: fix lib
    lib = pkgs.lib;
      
    inherit (secrets) ips ports;
  in
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
            useACMEHost = "nani.wtf";
            forceSSL = true;

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
      (proxy ["plex"] "http://localhost:${s ports.plex}" {})
      # (host ["www"] { root = "${inputs.website.packages.${pkgs.system}.default}/"; })
      (host ["www"] {
        locations."/" = {
          tryFiles = "$uri /index.html";
          root = pkgs.writeTextDir "index.html" ''
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Nani.wtf</title>
  <style>
    html, body { padding: 0; margin: 0; width: 100%; height: 100%; }
    * {box-sizing: border-box;}
    body { text-align: center; padding: 0; background: #d6433b; color: #fff; font-family: Open Sans; }
    h1 { font-size: 50px; font-weight: 100; text-align: center;}
    body { font-family: Open Sans; font-weight: 100; font-size: 20px; color: #fff; text-align: center; display: -webkit-box; display: -ms-flexbox; display: flex; -webkit-box-pack: center; -ms-flex-pack: center; justify-content: center; -webkit-box-align: center; -ms-flex-align: center; align-items: center;}
    article { display: block; width: 700px; padding: 50px; margin: 0 auto; }
    a { color: #fff; font-weight: bold;}
    a:hover { text-decoration: none; }
    svg { width: 75px; margin-top: 1em; }
  </style>
</head>
<body>
  <article>
    <h1>Nani.wtf</h1>
    <p style="font-size: 1.3em;">Down for maintenance</p>
    <p style="font-size: 1.1em;">Will be back soon!</p>

    <a href="https://git.nani.wtf">git.nani.wtf</a>
  </article>
</body>
</html>
          '';
        };
      })
      (host ["matrix"] {
        enableACME = lib.mkForce false;
        locations."/_synapse".proxyPass = "http://$synapse_backend";
      })
      (host ["madmin"] { root = "${pkgs.synapse-admin}/"; })
      # (host ["cache"] { root = "/var/lib/nix-cache"; })
      (proxy ["git"] "http://localhost:${s ports.gitea}" {})
      (proxy ["px1"] "https://${ips.px1}:${s ports.proxmox}" {
          locations."/".proxyWebsockets = true;
      })
      (proxy ["idrac"] "https://${ips.idrac}" {})
      (proxy ["log"] "http://localhost:${s ports.grafana}" {
        locations."/".proxyWebsockets = true;
      })
      (host ["pg"] {
        locations."/" = {
        extraConfig = ''
          include ${pkgs.nginx}/conf/uwsgi_params;
          uwsgi_pass unix:${config.services.uwsgi.instance.vassals.pgadmin.socket};
        '';
        };
      })
      # (proxy ["pg"] "http://localhost:${s ports.pgadmin}" {
      #   extraConfig = ''
      #     proxy_set_header X-CSRF-Token $http_x_pga_csrftoken;
      #   '';
      # })
      (proxy ["py"] "http://localhost:${s ports.jupyterhub}" {
        locations."/".proxyWebsockets = true;
      })
      (proxy ["docs"] "http://localhost:${s config.services.hedgedoc.settings.port}" {})
      (proxy ["map"] "http://localhost:${s ports.minecraft.dynmap}" {})
      (proxy ["yt"] "http://localhost:${s config.services.invidious.port}" {})
      (proxy ["osu"] "http://localhost:${s ports.osuchan}" {})
      (proxy ["auth"] "https://localhost:8300" {
        extraConfig = ''
          proxy_ssl_verify off;
        '';
      })
      (proxy ["hydra"] "http://localhost:${s ports.hydra}" {})
      (proxy ["atuin"] "http://localhost:${s config.services.atuin.port}" {})
      (proxy ["vpn"] "http://localhost:${s config.services.headscale.port}" {
        locations."/".proxyWebsockets = true;
      })
      (proxy ["hydra"] "http://localhost:${s config.services.hydra.port}" {})
    ] ++ (let
      stickerpickers = pkgs.callPackage ../matrix/maunium-stickerpicker.nix {
        inherit (inputs) maunium-stickerpicker secrets;
      };
    in [
      (host ["stickers-pingu"] { root = "${stickerpickers.stickers-pingu}/"; })
      (host ["stickers-h7x4"] { root = "${stickerpickers.stickers-h7x4}/"; })
    ])));
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
