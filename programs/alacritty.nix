{ lib, pkgs, colorTheme, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      window.padding = { x = 15; y = 15; };

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
            primary = getAttrs primaryColors colorTheme.default;
            normal = let
              removePrimaryColorAttrs = n: v: !(any (pc: n ? pc) primaryColors);
            in filterAttrs removePrimaryColorAttrs colorTheme.default;
          };

      background_opacity = 1.0;

      cursor = {
        style = "Block";
        blinking = "On";
        unfocused_hollow = true;
      };

      bell = {
        animation = "EaseOutExpo";
        color = "0xffffff";
        duration = 20;
      };

      live_config_reload = true;

      shell = {
        program = "${pkgs.zsh}/bin/zsh";
        args = [ "--login" ];
      };
    };
  };
}
