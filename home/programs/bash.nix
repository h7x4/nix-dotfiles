{ config, ... }:
{
  programs.bash = {
    enable = true;
    historyFile = "${config.xdg.dataHome}/bash_history";
    historySize = 100000;
    bashrcExtra = ''
      source "${config.xdg.configHome}/mutable_env.sh"
    '';
  };
}