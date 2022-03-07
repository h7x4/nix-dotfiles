{config, pkgs, lib, secrets, ...}: {

  # configure synapse to point users to coturn
  services.matrix-synapse = {
    enable = true;
    turn_uris = let 
      inherit (config.services.coturn) realm;
      p = toString secrets.ports.matrix.default;
    in ["turn:${realm}:${p}?transport=udp" "turn:${realm}:${p}?transport=tcp"];
    turn_shared_secret = config.services.coturn.static-auth-secret;
    turn_user_lifetime = "1h";

    server_name = "nani.wtf";
    public_baseurl = "https://matrix.nani.wtf";

    enable_metrics = true;

    listeners = [
      {
        port = secrets.ports.matrix.listener;
        bind_address = "::1";
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

    enable_registration = false;

    # password_config.enabled = lib.mkForce false;

    dataDir = "/data/var/matrix";

    database_type = "psycopg2";
    database_args = {
      password = "synapse";
    };

    # redis.enabled = true;

    # settings = {


 
    # };
  };

  services.redis.enable = true;

  # enable coturn
  services.coturn = rec {
    enable = true;
    no-cli = true;
    no-tcp-relay = true;
    min-port = secrets.ports.matrix.min;
    max-port = secrets.ports.matrix.max;
    use-auth-secret = true;
    static-auth-secret = secrets.keys.matrix.static-auth-secret;
    realm = "turn.nani.wtf";
    cert = "${secrets.keys.certificates.server.crt}";
    pkey = "${secrets.keys.certificates.server.key}";
    extraConfig = ''
      # for debugging
      verbose
      # ban private IP ranges
      no-multicast-peers
      denied-peer-ip=0.0.0.0-0.255.255.255
      denied-peer-ip=10.0.0.0-10.255.255.255
      denied-peer-ip=100.64.0.0-100.127.255.255
      denied-peer-ip=127.0.0.0-127.255.255.255
      denied-peer-ip=169.254.0.0-169.254.255.255
      denied-peer-ip=172.16.0.0-172.31.255.255
      denied-peer-ip=192.0.0.0-192.0.0.255
      denied-peer-ip=192.0.2.0-192.0.2.255
      denied-peer-ip=192.88.99.0-192.88.99.255
      denied-peer-ip=192.168.0.0-192.168.255.255
      denied-peer-ip=198.18.0.0-198.19.255.255
      denied-peer-ip=198.51.100.0-198.51.100.255
      denied-peer-ip=203.0.113.0-203.0.113.255
      denied-peer-ip=240.0.0.0-255.255.255.255
      denied-peer-ip=::1
      denied-peer-ip=64:ff9b::-64:ff9b::ffff:ffff
      denied-peer-ip=::ffff:0.0.0.0-::ffff:255.255.255.255
      denied-peer-ip=100::-100::ffff:ffff:ffff:ffff
      denied-peer-ip=2001::-2001:1ff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=2002::-2002:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff
    '';
  };

  services.postgresql = {
    enable = true;

    ## postgresql user and db name remains in the
    ## service.matrix-synapse.database_args setting which
    ## by default is matrix-synapse
    initialScript = pkgs.writeText "synapse-init.sql" ''
        CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
        CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
            TEMPLATE template0
            LC_COLLATE = "C"
            LC_CTYPE = "C";
        '';
  };

  # open the firewall
  networking.firewall = {
    interfaces.enp2s0 = let
      range = with config.services.coturn; [ {
      from = secrets.ports.matrix.min;
      to = secrets.ports.matrix.max;
    } ];
    in
    {
      allowedUDPPortRanges = range;
      allowedUDPPorts = [ secrets.ports.matrix.default ];
      allowedTCPPortRanges = range;
      allowedTCPPorts = [ secrets.ports.matrix.default ];
    };
  };
  # get a certificate
  # security.acme.certs.${config.services.coturn.realm} = {
  #   /* insert here the right configuration to obtain a certificate */
  #   postRun = "systemctl restart coturn.service";
  #   group = "turnserver";
  # };
}
