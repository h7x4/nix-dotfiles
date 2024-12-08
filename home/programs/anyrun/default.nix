{ pkgs, lib, inputs, ... }:
{
  programs.anyrun = {
    enable = true;

    config = {
      y.fraction = 0.3;
      width.fraction = 0.25;
      plugins = [
        inputs.anyrun.packages.${pkgs.system}.applications
      ];
      hidePluginInfo = true;
      closeOnClick = true;
    };

    extraCss = builtins.readFile (./. + "/style.css");

    extraConfigFiles."applications.ron".text = let
      preprocess_script = pkgs.writeShellApplication {
        name = "anyrun-preprocess-application-exec";
        runtimeInputs = [ ];
        text = ''
          shift # Remove term|no-term
          echo "uwsm app -- $*"
        '';
      };
    in ''
      Config(
        desktop_actions: false,
        max_entries: 10,
        preprocess_exec_script: Some("${lib.getExe preprocess_script}"),
        terminal: Some("${lib.getExe pkgs.alacritty}"),
      )
    '';
  };
}
