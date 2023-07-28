{ lib, config, ... }:
let
  inherit (lib) types mkEnableOption mkOption mkIf;
  cfg = config.machineVars;
in {
  # TODO: namespace these options behind `local`
  options.machineVars = {
    headless = mkEnableOption "Whether or not the machine should have graphical output.";

    screens = mkOption {
      type = types.attrsOf (types.submodule ( { name, ...}: {
        options = {
          name = mkOption {
            type = types.str;
            default = name;
            example = "DP-1";
            description = "The name of the screen";
          };

          primary = mkEnableOption "Whether this screen should be the primary one. There can only be one primary screen";

          resolution = mkOption {
            type = types.str;
            example = "3840x2160";
            default = "1920x1080";
            description = "The resolution of the screen";
          };

          frequency = mkOption {
            type = types.ints.positive;
            example = 144;
            default = 60;
            description = "The update frequency of the screen, defined in Hz";
          };

          position = mkOption {
            type = types.str;
            example = "1920x0";
            default = "0x0";
            description = "The position of the screen, compared to the other screens";
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

    wlanInterface = mkOption {
      type = types.nullOr types.string;
      default = null;
    };

    # Check " ls -1 /sys/class/power_supply/ "
    battery = mkOption {
      type = types.nullOr types.string;
      default = null;
    };

    laptop = mkEnableOption "Whether the machine is a laptop";

    fixDisplayCommand = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    dataDrives = let
      driveType =
        types.path;
      #   types.addCheck types.path (path: builtins.elem path (builtins.attrNames config.fileSystems));
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
      {
        assertion = cfg.battery != null -> cfg.laptop;
        message = "A battery shouldn't exist on a non laptop machine";
      }
      # FIXME:
      # {
      #   assertion = map () (cfg.screens)
      #   message = "There can only be one primary screen.";
      # }
    ];

    warnings = lib.optionals (0 < (lib.length (builtins.attrNames cfg.screens)) && (cfg.fixDisplayCommand != null)) [
      "You are overriding the fixDisplayCommand even though machineVars.screens is defined. One of these should be omitted"
    ];
  };
}

