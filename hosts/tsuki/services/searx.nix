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
     
      engines = let
        enable = name: {
          name = name;
          disabled = false;
        };
        disable = name: {
          name = name;
          disabled = true;
        };
      in [
        /* General */
        (disable "bing")
        /* --- */
        (enable "archive is")
        (enable "wikipedia")
        (enable "currency")
        (enable "ddg definitions")
        (enable "erowid")
        (enable "wikidata")
        (enable "duckduckgo")
        (enable "etymonline")
        (enable "google")
        (enable "library genesis")
        (enable "qwant")
        (enable "reddit")
        (enable "wikibooks")
        (enable "wikiquote")
        (enable "wikisource")
        (enable "wiktionary")
        (enable "wikiversity")
        # Doesn't work at the time
        # (enable "wikivoyage")
        (enable "dictzone")

        /* Files */
        # (disable "btdigg")
        (disable "piratebay")
        (disable "torrentz")
        /* --- */
        (enable "apk mirror")
        (enable "fdroid")
        (enable "google play apps")
        (enable "nyaa")
        (enable "tokyotoshokan")

        /* Images */
        (disable "bing images")
        (disable "ccengine")
        (disable "flickr")
        (disable "library of congress")
        /* --- */
        (enable "deviantart")
        (enable "google images")
        (enable "nyaa")
        # (enable "reddit")
        (enable "qwant images")
        (enable "unsplash")

        /* IT */
        (enable "arch linux wiki")
        (enable "bitbucket")
        (enable "free software directory")
        (enable "gentoo")
        (enable "gitlab")
        (enable "github")
        (enable "codeberg")
        (enable "hoogle")
        (enable "npm")
        (enable "stackoverflow")
        (enable "searchcode code")

        /* map */
        (enable "openstreetmap")
        (enable "photon")

        /* music */
        (disable "btdigg")
        /* --- */
        (enable "deezer")
        (enable "genius")
        (enable "mixcloud")
        # (enable "nyaa")
        (enable "soundcloud")
        # (enable "tokyotoshokan")
        (enable "youtube")

        /* news */
        (disable "bing news")
        (disable "digg")
        (disable "yahoo news")
        /* --- */
        (enable "google news")
        (enable "qwant news")
        # (enable "reddit")
        (enable "wikinews")

        /* science */
        (enable "arxiv")
        (enable "crossref")
        (enable "google scholar")
        (enable "microsoft academic")
        (enable "openairedatasets")
        (enable "openairepublications")
        (enable "pdbe")
        (enable "pubmed")
        (enable "semantic scholar")
        (enable "wolframalpha")

        /* social media */
        # (disable "digg")
        # (enable "reddit")

        /* shopping */
        # (enable "ebay")

        /* videos */
        (disable "bing videos")
        # (disable "piratebay")
        (disable "sepiasearch")
        (disable "dailymotion")
        (disable "mediathekviewweb")
        /* --- */
        (enable "google videos")
        # (enable "nyaa")
        # (enable "tokyotoshokan")
        # (enable "youtube")
        (enable "vimeo")
        (enable "peertube")
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
