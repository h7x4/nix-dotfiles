{ pkgs, lib, inputs, ... }:
{
  programs.anyrun = {
    enable = true;

    config = {
      y.fraction = 0.3;
      width.fraction = 0.25;
      plugins = [
        "${pkgs.anyrun}/lib/libapplications.so"
      ];
      hidePluginInfo = true;
      closeOnClick = true;
      showResultsImmediately = true;
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
        terminal: Some(Terminal(
          command: "${lib.getExe pkgs.alacritty}",
          args: "-e {}",
        )),
      )
    '';
  };
}
