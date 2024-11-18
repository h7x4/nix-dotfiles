{ config, lib, ... }:
{
  # 100.120.148.116
  services.samba = {
    enable = true;
    # openFirewall = true;

    settings = {
      global = {
        "workgroup" = "TSUKI";
        "server string" = "smbnix";
        "netbios name" = "smbnix";

        "security" = "user";

        "use sendfile" = "yes";
        "min protocol" = "SMB2";
        "smb encrypt" = "desired";

        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "100.107.69.8 100.100.65.88";
        "hosts deny" = "0.0.0.0/0";

        "guest ok" = "no";
        "map to guest" = "never";
      };
      cirno = {
        path = "/data/cirno";
        browseable = "yes";
        "valid users" = "h7x4";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0600";
        "directory mask" = "0700";
        "force user" = "h7x4";
        "force group" = "users";
        "comment" = "cirno data drive";
      };
      backup-import = {
        path = "/data/backup/import";
        browseable = "yes";
        "valid users" = "h7x4";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0600";
        "directory mask" = "0700";
        "force user" = "h7x4";
        "force group" = "users";
        "comment" = "backup import drive";
      };
      media = {
        path = "/data/media";
        browseable = "yes";
        "valid users" = "h7x4";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "media";
        "force group" = "media";
        "comment" = "media drive";
      };
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 139 445 ];
  networking.firewall.interfaces."tailscale0".allowedUDPPorts = [ 137 138 ];
}
