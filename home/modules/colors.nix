{ pkgs, lib, config, ... }:
let
  cfg = config.colors;
  inherit (lib) types mkOption;
in {
  options.colors = let
    colorType = types.str;

    mkColorOption = mkOption {
      type = colorType;
    };

    colorSetType = types.submodule ({ name, ... }: {
      options = {
        name = mkOption {
          type = types.str;
          default = name;
        };
        foreground = mkColorOption;
        background = mkColorOption;
        black      = mkColorOption;
        red        = mkColorOption;
        green      = mkColorOption;
        yellow     = mkColorOption;
        blue       = mkColorOption;
        magenta    = mkColorOption;
        cyan       = mkColorOption;
        white      = mkColorOption;
      };
    });

  in {
    colorSets = mkOption {
      type = types.attrsOf colorSetType;
    };
    defaultColorSet = mkOption {
      description = "the default color to use for applications";
      type = colorSetType;
    };
  };

  config.colors = rec {
    colorSets = {
      monokai = rec {
        foreground = white;
        background = black;
        black   = "#272822";
        red     = "#f92672";
        green   = "#a6e22e";
        yellow  = "#f4bf75";
        blue    = "#66d9ef";
        magenta = "#ae81ff";
        cyan    = "#a1efe4";
        white   = "#f8f8f2";
      };

      paper = {
        background = "#f2e3bd";
        foreground = "#2f343f";
        black   = "#222222";
        red     = "#C30771";
        green   = "#10A778";
        yellow  = "#A89C14";
        blue    = "#008ec4";
        magenta = "#523C79";
        cyan    = "#20A5BA";
        white   = "#f7f3ee";
      };
    };
    defaultColorSet = colorSets.monokai;
  };
}

