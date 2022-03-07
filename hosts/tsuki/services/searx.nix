{ secrets, ... }:
{
  # TODO: Make secret keys.
  services.searx = {
    enable = true;
    settings = {

      general = {
        debug = false;
        instance_name = "Searx";
      };

      server = {
        port = secrets.ports.searx;
        bind_address = "0.0.0.0";
        secret_key = secrets.keys.searx.key;
      };

      ui = {
        default_theme = "oscar";
        theme_args.oscar_style = "logicodev-dark";
      };
     
      engines = [
        # {
        #   name = "YouTube";
        #   shortcut = "yt";
        #   engine = "youtube_api";
        # }
        {
          name = "fdroid";
          engine = "fdroid";
        }
        {
          name = "github";
          engine = "github";
        }
        {
          name = "ebay";
          engine = "ebay";
        }
        # {
        #   name = "bandcamp";
        #   engine = "bandcamp";
        # }
        {
          name = "arch_linux_wiki";
          shortcut = "aw";
          engine = "archlinux";
        }
      ];
    };

    # runInUwsgi = true;
    # uwsgiConfig = {
      # disable-logging = false;
      # http = ":11000";
      # socket = "/run/searx/searx.sock";
    # };
  };
}
