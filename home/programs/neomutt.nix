{ config, lib, ... }:
let
  cfg = config.programs.neomutt;
in lib.mkIf cfg.enable {
  programs.neomutt = {
    vimKeys = true;
    sidebar.enable = true;

    settings = {
      debug_file = "${config.xdg.dataHome}/neomutt/debug0";
      history_file = "${config.xdg.dataHome}/neomutt/history";
      mailcap_path = "${config.xdg.configHome}/neomutt/mailcap";
      # header_cache = "${config.xdg.cacheHome}/neomutt/headers";
      # message_cache_dir = "${config.xdg.cacheHome}/neomutt/messages";
      news_cache_dir = "${config.xdg.cacheHome}/neomutt/news";
      tmp_dir = "/run/user/${toString config.home.uid}/neomutt";
      alias_file = "${config.xdg.dataHome}/neomutt/aliases";
    };

    extraConfig = ''
      source "${config.xdg.dataHome}/neomutt/aliases"

      # vim: filetype=neomuttrc
    '';
  };

  xdg.configFile."neomutt/mailcap".text = ''
    # vim: filetype=muttrc

    text/plain; nvim %s

    #PDFs
    application/pdf; zathura %s pdf

    #Images
    image/png; feh %s
    image/jpeg; feh %s
  '';
}
