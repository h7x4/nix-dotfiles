{ config, pkgs, secrets, ... }:
let
  inherit (secrets) ips ports;
in {
  services = {
    openvpn.servers = let
      inherit (secrets.keys.certificates) openvpn CA server;
      inherit (secrets.openvpn) ip-range;
    in {
      tsuki = {
        config = ''
          dev tap
          server-bridge ${ips.tsuki} 255.255.255.0 ${ip-range.start} ${ip-range.end} 
          local 0.0.0.0
          port ${toString ports.openvpn}
          user nobody
          group nogroup
          comp-lzo no
          push 'comp-lzo no'
          persist-key
          persist-tun
          keepalive 10 120
          topology subnet
          push "dhcp-option DNS 1.1.1.1"
          push "dhcp-option DNS 8.8.8.8"
          dh none
          ecdh-curve prime256v1
          tls-crypt ${openvpn.tls-crypt}
          ca ${CA.crt}
          cert ${server.crt}
          key ${server.key}
          auth SHA256
          cipher AES-128-GCM
          ncp-ciphers AES-128-GCM
          tls-server
          tls-version-min 1.2
          tls-cipher TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256
          status /var/openvpn/status.log
          verb 3
        '';
        autoStart = false;
        updateResolvConf = true;
      };
    };
  };

  networking.firewall = {
    allowedUDPPorts = [ ports.openvpn ];
    allowedTCPPorts = [ ports.openvpn ];
  };

  # networking.bridges.br0.interfaces = [ "tap0" "ens18" ];
}
