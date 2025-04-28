{ config, pkgs, lib, ... }: let
  cfg = config.services.matrix-appservice-irc;
in {
  sops = {
    secrets = {
      "matrix/bridges/irc/id" = {};
      "matrix/bridges/irc/hs_token" = {};
      "matrix/bridges/irc/as_token" = {};
    };

    templates."matrix-appservice-irc-registration.yml" = {
      owner = "matrix-appservice-irc";
      group = "matrix-synapse";
      mode = "0440";
      file = let
        inherit (config.sops) placeholder;
      in (pkgs.formats.yaml {}).generate "matrix-appservice-irc-registration.yml" {
        id = placeholder."matrix/bridges/irc/id";
        hs_token = placeholder."matrix/bridges/irc/hs_token";
        as_token = placeholder."matrix/bridges/irc/as_token";
        url = cfg.registrationUrl;
        sender_localpart = cfg.localpart;
        "de.sorunome.msc2409.push_ephemeral" = true;
        protocols = [ "irc" ];
        namespaces = {
          aliases = [
            {
              exclusive = true;
              regex = "#lainchanirc_.*:nani\\.wtf";
            }
            {
              exclusive = true;
              regex = "#liberairc_.*:nani\\.wtf";
            }
          ];
          users = [
            {
              exclusive = true;
              regex = "@lainanon_.*:nani\\.wtf";
            }
            {
              exclusive = true;
              regex = "@liberauser_.*:nani\\.wtf";
            }
          ];
        };
        rate_limited = false;
      };
    };
  };

  services.matrix-appservice-irc = {
    enable = true;
    registrationUrl = "http://localhost:${toString cfg.port}";

    settings = {
      homeserver = {
        url = "https://matrix.nani.wtf";
        domain = "nani.wtf";
        enablePresence = true;
      };

      database = {
        engine = "postgres";
        # TODO: use unix socket
        connectionString = "postgres://matrix-appservice-irc:@localhost:${toString config.services.postgresql.settings.port}/matrix-appservice-irc?sslmode=disable";
      };

      ircService = {
        mediaProxy.publicUrl = "https://irc-matrix.nani.wtf/media";

        servers = {
          "irc.libera.chat" = {
            name = "libera";
            port = 6697;
            ssl = true;
            networkId = "ircLiberaChat";

            botConfig.enable = false;

            dynamicChannels = {
              enabled = true;
              createAlias = true;
              aliasTemplate = "#liberairc_$CHANNEL";
              published = true;
              useHomeserverDirectory = true;
              joinRule = "public";
              federate = true;
            };

            matrixClients = {
              userTemplate = "@liberauser_$NICK";
            };

            ircClients = {
              nickTemplate = "$LOCALPART[m]";
              allowNickChanges = true;
            };

            membershipLists = {
              enabled = true;
              global = {
                ircToMatrix = {
                  initial = true;
                  incremental = true;
                };
                matrixToIrc = {
                  initial = true;
                  incremental = true;
                };
              };
            };

            permissions."@h7x4:nani.wtf" = "admin";

            # TODO: Port forward
            ident.enable = true;

            # TODO: Metrics
          };

          "irc.lainchan.org" = {
            name = "lainchan";
            port = 6697;
            ssl = true;
            networkId = "ircLainchanOrg";

            botConfig.enable = false;

            dynamicChannels = {
              enabled = true;
              createAlias = true;
              aliasTemplate = "#lainchanirc_$CHANNEL";
              published = true;
              useHomeserverDirectory = true;
              joinRule = "public";
              federate = true;
            };

            matrixClients = {
              userTemplate = "@lainanon_$NICK";
            };

            ircClients = {
              nickTemplate = "$LOCALPART[m]";
              allowNickChanges = true;
            };

            membershipLists = {
              enabled = true;
              global = {
                ircToMatrix = {
                  initial = true;
                  incremental = true;
                };
                matrixToIrc = {
                  initial = true;
                  incremental = true;
                };
              };
            };

            permissions."@h7x4:nani.wtf" = "admin";

            # TODO: Port forward
            ident.enable = true;

            # TODO: Metrics
          };
        };
      };
    };
  };

  services.matrix-synapse-next.settings.app_service_config_files = [
    config.sops.templates."matrix-appservice-irc-registration.yml".path
  ];

  systemd.services.matrix-appservice-irc = {
    enableStrictShellChecks = false;
    requires = [
      "matrix-synapse.service"
      "postgresql.service"
    ];

    serviceConfig.BindReadOnlyPaths = [
      "${config.sops.templates."matrix-appservice-irc-registration.yml".path}:/var/lib/matrix-appservice-irc/registration.yml"
    ];

    preStart = lib.mkForce ''
      umask 077
      # Generate key for crypting passwords
      if ! [ -f "${cfg.settings.ircService.passwordEncryptionKeyPath}" ]; then
        ${pkgs.openssl}/bin/openssl genpkey \
            -out "${cfg.settings.ircService.passwordEncryptionKeyPath}" \
            -outform PEM \
            -algorithm RSA \
            -pkeyopt "rsa_keygen_bits:${toString cfg.passwordEncryptionKeyLength}"
      fi

      if ! [ -f "${cfg.settings.ircService.mediaProxy.signingKeyPath}"]; then
        ${lib.getExe pkgs.nodejs} ${pkgs.matrix-appservice-irc}/lib/generate-signing-key.js > "${cfg.settings.ircService.mediaProxy.signingKeyPath}"
      fi
    '';
  };
}
