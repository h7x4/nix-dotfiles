{ config, lib, pkgs, extendedLib, ... }:
let
  cfg = config.programs.ghci;
in
{
  options.programs.ghci = {
    enable = lib.mkEnableOption "ghci, interactive haskell shell";

    package = lib.mkPackageOption pkgs "ghc" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Personal config
    xdg.configFile = {
      "ghc/ghci.conf".text = ''
        :set prompt "${extendedLib.termColors.front.magenta "[GHCi]λ"} "
      '';
    };
  };
}
