{ pkgs, lib, config, ... }: {
  imports = [
    ./bridges/matrix-appservice-irc.nix

    ./maunium-stickerpicker.nix

    ./postgres.nix
    ./coturn.nix
  ];

  sops.secrets."matrix_synapse/registration_secret" = {
    owner = "matrix-synapse";
    group = "matrix-synapse";
    mode = "0440";
  };

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

      trusted_key_servers = [
        {
          server_name = "matrix.org";
          verify_keys."ed25519:a_RXGa" = "l8Hft5qXKn1vfHrg3p4+W8gELQVo8N13JkluMfmn2sQ";
        }
        {
          server_name = "pvv.ntnu.no";
          verify_keys."ed25519:a_iMup" = "Fk1TzI2PM8ckKMs0ezLSt3YPwPFwLvyV4NzIcabKUEI";
        }
        {
          server_name = "feal.no";
          verify_keys."ed25519:a_EDCk" = "zJ+SwXYtENAg26iRHQeNC7hUh4vOFscon2OpUuYIck0";
        }
        {
          server_name = "dodsorf.as";
          verify_keys."ed25519:a_fxFt" = "DJWwWzOEnxE8+keT+JNCKz7spMXb05r4SrF2y3rcONI";
        }
      ];

      server_name = "nani.wtf";
      public_baseurl = "https://matrix.nani.wtf";
      web_client_location = "https://chat.pvv.ntnu.no";

      enable_metrics = true;

      # NOTE: To register a new admin user, use a nix-shell with
      # package 'matrix-synapse', and use the register_new_matrix_user command
      # with the registration shared secret
      enable_registration = false;

      registration_shared_secret_path = config.sops.secrets."matrix_synapse/registration_secret".path;
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
