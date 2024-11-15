{ pkgs, lib, config, secrets, ... }: {

  imports = [
    ./bridges/matrix-appservice-irc.nix

    ./maunium-stickerpicker.nix

    ./postgres.nix
    ./coturn.nix
  ];

  services.matrix-synapse-next = {
    enable = true;
    enableNginx = true;
    dataDir = "/var/lib/matrix";

    workers = {
      federationSenders = 2;
      federationReceivers = 2;
      initialSyncers = 1;
      normalSyncers = 1;
      eventPersisters = 1;
      useUserDirectoryWorker = true;
    };

    settings = {
      turn_uris = let
        inherit (config.services.coturn) realm listening-port;
      in [
        "turn:${realm}:${toString listening-port}?transport=udp"
        "turn:${realm}:${toString listening-port}?transport=tcp"
      ];
      turn_shared_secret = config.services.coturn.static-auth-secret;
      turn_user_lifetime = "1h";

      trusted_key_servers = let
        emptykey = server_name: {
          inherit server_name;
          verify_keys = {};
        };
      in [
        {
          server_name = "matrix.org";
          verify_keys."ed25519:auto" = "Noi6WqcDj0QmPxCNQqgezwTlBKrfqehY1u2FyWP9uYw";
        }
        (emptykey "pvv.ntnu.no")
        (emptykey "feal.no")
        (emptykey "dodsorf.as")
      ];

      server_name = "nani.wtf";
      public_baseurl = "https://matrix.nani.wtf";

      enable_metrics = true;

      # NOTE: To register a new admin user, use a nix-shell with
      # package 'matrix-synapse', and use the register_new_matrix_user command
      # with the registration shared secret
      enable_registration = false;

      registration_shared_secret = secrets.keys.matrix.registration-shared-secret;
      allow_public_rooms_over_federation = true;

      # password_config.enabled = lib.mkForce false;

      database = {
        name = "psycopg2";
        args = {
          user = "matrix-synapse";
          database = "matrix-synapse";
          host = "/var/run/postgresql";
          port = config.services.postgresql.settings.port;
        };
      };

      # TODO: Figure out a way to do this declaratively.
      #       The files need to be owned by matrix-synapse
      app_service_config_files = [
        "/var/lib/matrix-synapse/irc-registration.yml"
      ];

      # redis.enabled = true;
      max_upload_size = "100M";
      dynamic_thumbnails = true;
    };
  };

  systemd.slices.system-matrix-synapse = {
    requires = [
      "postgresql.service"
      "redis.service"
      "kanidm.service"
    ];
  };

  services.redis.servers."".enable = true;
}
