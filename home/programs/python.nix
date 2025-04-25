{ config, pkgs, extendedLib, ... }:
{
  # Python for interactive use
  home.packages = [
    (pkgs.python3.withPackages (pypkgs: with pypkgs; [
      requests
    ]))
  ];

  xdg.configFile."python/pyrc".text = ''
    #!/usr/bin/env python3
    import sys

    # You also need \x01 and \x02 to separate escape sequence, due to:
    # https://stackoverflow.com/a/9468954/1147688
    sys.ps1='\x01\x1b${extendedLib.termColors.front.blue "[Python]> "}\x02>>>\x01\x1b[0m\x02 '  # bright yellow
    sys.ps2='\x01\x1b[1;49;31m\x02...\x01\x1b[0m\x02 '  # bright red
  '';

  home.sessionVariables = {
    PYTHONSTARTUP = "${config.xdg.configHome}/python/pyrc";
    PYTHON_HISTORY = "${config.xdg.dataHome}/python_history";
  };
}
