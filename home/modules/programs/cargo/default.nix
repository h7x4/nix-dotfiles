{ config, pkgs, lib, ... }:
let
  cfg = config.programs.cargo;
  format = pkgs.formats.toml { };
  cargoHome = config.home.sessionVariables.CARGO_HOME or "${config.home.homeDirectory}/.cargo";
  relativeCargoHome = lib.strings.removePrefix config.home.homeDirectory cargoHome;
in
{
  options.programs.cargo = {
    enable = lib.mkEnableOption "cargo, the rust package manager and build tool";

    package = lib.mkPackageOption pkgs "cargo" { };

    addPackageToEnvironment = lib.mkOption {
      description = "Whether to add cargo to the user's environment.";
      type = lib.types.bool;
      default = true;
      example = false;
    };

    settings = lib.mkOption {
      description = "cargo settings";
      type = lib.types.submodule {
        freeformType = format.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      sessionVariables.CARGO_HOME = lib.mkIf config.home.preferXdgDirectories (lib.mkDefault "${config.xdg.dataHome}/cargo");

      packages = lib.mkIf cfg.addPackageToEnvironment [ cfg.package ];

      file."${relativeCargoHome}/config.toml" = lib.mkIf (cfg.settings != { }) {
        source = format.generate "cargo-config.toml" cfg.settings;
      };
    };
  };
}
