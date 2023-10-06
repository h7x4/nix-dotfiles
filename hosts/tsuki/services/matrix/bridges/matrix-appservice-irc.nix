{ config, ... }: let
  cfg = config.services.matrix-appservice-irc;
in {
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
        connectionString = "postgres://matrix-appservice-irc:@localhost:${toString config.services.postgresql.port}/matrix-appservice-irc?sslmode=disable";
      };

      ircService.servers."irc.lainchan.org" = {
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

  systemd.services.matrix-appservice-irc = {
    requires = [
      "matrix-synapse.service"
      "postgresql.service"
    ];
  };
}
