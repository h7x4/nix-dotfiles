{ secrets, ... }:
{
  services.mautrix-facebook = {
    enable = false;
    configurePostgresql = true;

    registrationData = {
      # NOTE: This is a randomly generated UUID
      inherit (secrets.keys.matrix.mautrix-facebook) as_token;
      inherit (secrets.keys.matrix.mautrix-facebook) hs_token;
    };

    settings = {
      homeserver = {
        # TODO: connect via localhost
        address = "https://matrix.nani.wtf";
        domain = "nani.wtf";
      };
    
      appservice = rec {
        address = "http://${hostname}:${toString port}";
        bot_username = "facebookbot";
        hostname = "0.0.0.0";

        ephemeral_events = true;

        port = secrets.ports.matrix.mautrix-facebook;
        inherit (secrets.keys.matrix.mautrix-facebook) as_token;
        inherit (secrets.keys.matrix.mautrix-facebook) hs_token;
      };

      bridge = {
        encryption = {
          allow = true;
          default = true;
        };
        backfilling = {
          initial_limit = 8000;
        };
        username_template = "facebook_{userid}";
        sync_with_custom_puppets = false;
        permissions = {
          "@h7x4:nani.wtf" = "admin";
          "nani.wtf" = "user";
        };
      };

      logging = {
        formatters = {
          journal_fmt = {
            format = "%(name)s: %(message)s";
          };
        };
        handlers = {
          journal = {
            SYSLOG_IDENTIFIER = "mautrix-facebook";
            class = "systemd.journal.JournalHandler";
            formatter = "journal_fmt";
          };
        };
        root = {
          handlers = [
            "journal"
          ];
          level = "INFO";
        };
        version = 1;
      };

      manhole = {
        enabled = false;
      };

      metrics = {
        enabled = false;
      };
    };
  };
}
