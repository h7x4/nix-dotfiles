{ pkgs, config, ... }:
let
  inherit (pkgs) lib;
  inherit (lib) types mkEnableOption mkOption mkIf;
  cfg = config.machineVars;
in {
  options.machineVars = {
    headless = mkEnableOption "Whether or not the machine should have graphical output.";

    screens = mkOption {
      type = types.attrsOf (types.submodule ( { name, ...}: {
        options = {
          resolution = mkOption {
            type = types.str;
            example = "1920x1080";
            description = "The resolution of the screen";
          };

          name = mkOption {
            type = types.str;
            default = name;
            example = "DP-1";
            description = "The name of the screen";
          };

          freq = mkOption {
            type = types.nullOr types.str;
            example = "60.00";
            description = "The update frequency of the screen, defined in Hz";
          };
        };
      }));
      default = { };
      description = "A detailed description of the machines screens.";
    };

    gaming = mkEnableOption "Whether or not the machine should have gaming software installed.";
    development = mkEnableOption "Whether or not the machine should come with developmen
t tools preinstalled.";
    creative = mkEnableOption "Whether or not the machine should have creative software
(music, video and image editing) installed.";

    laptop = mkEnableOption "Whether the machine is a laptop";

    fixDisplayCommand = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    dataDrives = let 
      driveType =
        types.addCheck types.path (path: builtins.elem path (builtins.attrNames config.fileSystems));
    in {
      drives = mkOption {
        type = types.attrsOf driveType;
        default = { };
        example = {
          dataDrive1 = "/data/data1";
          dataDrive2 = "/another/location";
        };
        description = ''
          Drives that should act as data drives.
          These need to be registered in `fileSystems`
        '';
      };

      default = mkOption {
        type = types.nullOr driveType;
        description = ''
          Data drive that should be used for most purposes.
        '';
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.headless -> !cfg.creative;
        message = "A headless machine can't have creative software installed.";
      }
      {
        assertion = cfg.headless -> !cfg.gaming;
        message = "A headless machine can't have gaming software installed.";
      }
      {
        assertion = cfg.headless -> (cfg.screens == { } && cfg.fixDisplayCommand == null);
        message = "A headless machine can't have any screens.";
      }
    ];

    warnings = lib.optionals (0 < (lib.length (builtins.attrNames cfg.screens)) && (cfg.fixDisplayCommand != null)) [
      "You are overriding the fixDisplayCommand even though machineVars.screens is defined. One of these should be omitted"
    ];
  };
}

