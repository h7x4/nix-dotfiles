{ pkgs, lib, config, secrets, ... }: {

  imports = [
    ./bridges/mautrix-facebook.nix
    ./bridges/mx-puppet-discord.nix
    # TODO: fix irc service
    # ./bridges/matrix-appservice-irc.nix

    ./postgres.nix
    ./coturn.nix
  ];

  services.matrix-synapse = {
    enable = true;
    settings = {
      turn_uris = let
        inherit (config.services.coturn) realm;
        p = toString secrets.ports.matrix.default;
      in ["turn:${realm}:${p}?transport=udp" "turn:${realm}:${p}?transport=tcp"];
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
          verify_keys = {
            "ed25519:auto" = "Noi6WqcDj0QmPxCNQqgezwTlBKrfqehY1u2FyWP9uYw";
          };
        }
        (emptykey "pvv.ntnu.no")
        (emptykey "feal.no")
        (emptykey "dodsorf.as")
      ];

      server_name = "nani.wtf";
      public_baseurl = "https://matrix.nani.wtf";

      enable_metrics = true;

      listeners = [
        {
          port = secrets.ports.matrix.listener;
          bind_addresses = [
            "0.0.0.0"
            "::1"
          ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [ "client" "federation" "metrics" ];
              compress = false;
            }
          ];
        }
      ];

      # NOTE: To register a new admin user, use a nix-shell with
      # package 'matrix-synapse', and use the register_new_matrix_user command
      # with the registration shared secret
      enable_registration = false;

      registration_shared_secret = secrets.keys.matrix.registration-shared-secret;

      # password_config.enabled = lib.mkForce false;

      dataDir = "${config.machineVars.dataDrives.default}/var/matrix";

      database_type = "postgres";
      # database_args = {
      #   password = "synapse";
      # };

      # TODO: Figure out a way to do this declaratively.
      #       The files need to be owned by matrix-synapse
      app_service_config_files = [
        "/var/lib/matrix-synapse/discord-registration.yaml"
        # (pkgs.writeText "facebook-registrations.yaml" (builtins.toJSON config.services.mautrix-facebook.registrationData))
        "/var/lib/matrix-synapse/facebook-registration.yaml"
      ];

      # redis.enabled = true;
      max_upload_size = "100M";
    };
  };

  # services.redis.enable = true;

  networking.firewall = {
    interfaces.enp2s0 = let
      range = with config.services.coturn; [ {
      from = secrets.ports.matrix.coturn.min;
      to = secrets.ports.matrix.coturn.max;
    } ];
    in
    {
      allowedUDPPortRanges = range;
      allowedUDPPorts = [ secrets.ports.matrix.default ];
      allowedTCPPortRanges = range;
      allowedTCPPorts = [ secrets.ports.matrix.default ];
    };
  };
}
