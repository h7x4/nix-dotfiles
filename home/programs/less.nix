{ config, ... }:
{
  programs.less = {
    enable = true;
    keys = ''
      #env
      LESS = -i -R
      LESSHISTSIZE=20000
      LESSHISTFILE=${config.xdg.dataHome}/less/history
    '';
  };
}
