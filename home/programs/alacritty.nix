{ pkgs, lib, config, ... }:
{
  programs.alacritty = {
    settings = {
      window = {
        padding = { x = 15; y = 15; };
        opacity = 1.0;
      };

      font = {
        normal = {
          family = "Fira Code";
          style = "Retina";
        };
        bold.family = "Fira Code";
        italic.family = "Fira Code";
        size = 12.0;
      };

      colors =
        let
          inherit (lib.attrsets) getAttrs filterAttrs;
          inherit (lib.lists) any;
          primaryColors = [ "foreground" "background" ];
        in
          {
            primary = getAttrs primaryColors config.colors.defaultColorSet;
            normal = builtins.removeAttrs config.colors.defaultColorSet (primaryColors ++ [ "name" ]);
          };

      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };
        unfocused_hollow = true;
      };

      bell = {
        animation = "EaseOutExpo";
        color = "0xffffff";
        duration = 20;
      };

      general.live_config_reload = true;

      terminal.shell = {
        program = "${pkgs.zsh}/bin/zsh";
        args = [ "--login" ];
      };
    };
  };
}
