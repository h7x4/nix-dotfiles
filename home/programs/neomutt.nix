{ config, lib, ... }:
let
  cfg = config.programs.neomutt;
in lib.mkIf cfg.enable {
  programs.neomutt = {
    # vimKeys = true;
    # set mailcap_path = ~/.config/neomutt/mailcap
    # set header_cache = "~/.cache/mutt"
    # set message_cachedir = "~/.cache/mutt"
    # set tmpdir = /run/user/${uid}/mutt

    # extraConfig = ''
    #   # vim: filetype=muttrc
    # '';
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
