{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [ zed-editor ];

  xdg.configFile."zed/settings.json".source = let
    format = pkgs.formats.json { };
  in format.generate "zed-settings.json" {
    autosave = "off";
    buffer_font_family = "Fira Code";
    load_direnv = "shell_hook";
    format_on_save = "off";

    telemetry = {
      diagnostics = false;
      metrics = false;
    };

    vim_mode = true;

    theme = {
      mod = "dark";
      dark = "monokai Classic";
    };
  };

  xdg.configFile."zed/themes/monokai.json".source = let
    package = pkgs.fetchFromGitHub {
      owner = "billgo";
      repo = "monokai";
      rev = "061a86ff4845b11ac2f183c2e26c77b15cfae7d0";
      hash = "sha256-mlEcgnLStYH1pV3p1iqNSvfVu4MpvpEOc+vxI+90MJs=";
    };
  in "${package}/themes/monokai.json";
}
