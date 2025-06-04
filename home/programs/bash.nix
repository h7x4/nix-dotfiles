{ config, lib, ... }:
let
  cfg = config.programs.bash;
in
{
  programs.bash = {
    historyFile = "${config.xdg.dataHome}/bash_history";
    historySize = 100000;
    bashrcExtra = ''
      source "${config.xdg.configHome}/mutable_env.sh"
    '';
    shellOptions = [
      "histappend"
      "checkwinsize"
      "checkjobs"
    ];
  };
}
