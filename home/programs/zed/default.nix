{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;

    userSettings = {
      load_direnv = "shell_hook";
      base_keymap = "VSCode";

      autosave = "off";
      format_on_save = "off";
      remove_trailing_whitespace_on_save = false;

      tab_size = 2;

      ui_font_family = "Noto Sans";
      buffer_font_family = "Fira Code";
      terminal.font_family = "Fira Code";

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      vim_mode = true;

      theme = {
        mode = "dark";
        light = "monokai Classic";
        dark = "monokai Darker Classic";
      };

      file_scan_exclusions = [
        "**/.git"
        "**/.svn"
        "**/.hg"
        "**/.jj"
        "**/CVS"
        "**/.DS_Store"
        "**/Thumbs.db"
        "**/.classpath"
        "**/.settings"

        "**/.direnv"
      ];

      git.inline_blame.enable = false;

      indent_guides = {
        enabled = true;
        coloring = "indent_aware";
      };
    };

    userKeymaps = [
      {
        context = "Workspace";
        bindings = {
          ctrl-j = "workspace::NewTerminal";
        };
      }
    ];

    extensions = [
      "basher"
      "dart"
      "dockerfile"
      "html"
      "nix"
      "sql"
      "toml"
    ];
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
