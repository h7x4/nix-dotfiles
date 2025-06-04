{ config, ... }:
{
  programs.less = {
    keys = ''
      #env
      LESS = -i -R
      LESSHISTSIZE=20000
      LESSHISTFILE=${config.xdg.dataHome}/less/history
    '';
  };
}
