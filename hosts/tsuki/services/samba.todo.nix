{}:
{
  services.samba = {
    enable = true;

    extraConfig = ''
    '';

    shares = {
      plex = {
        path = "/data/media";
        "read only" = false;
        browseable = "yes";
        "guest ok" = "no";
        comment = "Pictures, music, videos, etc.";
      };

      # home = {
        
      # };
    };
  };
}
