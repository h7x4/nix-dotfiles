{ config, ... }:
{
  services.samba = {
    enable = true;
    openFirewall = true;
    securityType = "user";

    extraConfig = ''
      workgroup = TSUKI
      server string = smbnix
      netbios name = smbnix

      security = user 

      use sendfile = yes
      min protocol = SMB2
      smb encrypt = desired

      # note: localhost is the ipv6 localhost ::1
      hosts allow = 10.0.0. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0

      guest ok = no
      map to guest = never
    '';

    shares = {
      media = {
        "path" = "${config.machineVars.dataDrives.default}/media";
        "read only" = false;
        "browseable" = "yes";
        "guest ok" = "no";
        "force group" = "media";
        "create mask" = "0644";
        "directory mask" = "0755";
        "comment" = "Pictures, music, videos, etc.";
      };

      momiji = {
        "path" = config.machineVars.dataDrives.drives.momiji;
        "read only" = false;
        "browseable" = "yes";
        "guest ok" = "no";
        "valid users" = "h7x4";
        "create mask" = "0644";
        "directory mask" = "0755";
        "comment" = "Momiji data drive.";
      };

      cirno = {
        "path" = config.machineVars.dataDrives.drives.cirno;
        "read only" = false;
        "browseable" = "yes";
        "guest ok" = "no";
        "valid users" = "h7x4";
        "create mask" = "0644";
        "directory mask" = "0755";
        "comment" = "Cirno data drive.";
      };

      home = {
        "path" = config.users.users.h7x4.home;
        "read only" = false;
        "browseable" = "yes";
        "guest ok" = "no";
        "valid users" = "h7x4";
        "create mask" = "0644";
        "directory mask" = "0755";
        "comment" = "Home directory.";
      };
    };
  };
}
