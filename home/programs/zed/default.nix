{ pkgs, yet-unstabler-pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;

    package = yet-unstabler-pkgs.zed-editor;

    userSettings = {
      load_direnv = "shell_hook";
      base_keymap = "VSCode";

      autosave = "off";
      format_on_save = "off";
      remove_trailing_whitespace_on_save = false;

      tab_size = 2;

      ui_font_family = "Noto Sans";
      ui_font_size = 18;

      buffer_font_family = "Fira Code";
      buffer_font_size = 16;

      terminal.font_family = "Fira Code";
      termial.font_size = 16;

      file_types = {
        "Groovy" = [ "Jenkinsfile*" ];
        "Dockerfile" = [ "Dockerfile*" ];
        "JSONC" = [ "json5" ];
      };

      tabs = {
        file_icons = true;
        show_close_button = "always";
        show_diagnostics = "errors";
      };

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      diagnostics = {
        include_warnings = true;
        inline.enabled = true;
        update_with_cursor = false;
        primary_only = false;
        use_rendered = false;
      };

      relative_linue_numbers = true;

      vim_mode = true;
      vim = {
        toggle_relative_line_numbers = true;
      };

      theme = {
        mode = "dark";
        light = "monokai Classic";
        dark = "monokai Darker Classic";
      };

      icon_theme = "Material Icon Theme";

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

      git_status = true;
      git.inline_blame.enabled = false;

      collaboration_panel.button = false;

      preview_tabs.enable = false;

      indent_guides = {
        enabled = true;
        coloring = "indent_aware";
      };
    };

    userKeymaps = [
      {
        bindings = {
          ctrl-b = "workspace::ToggleLeftDock";
          ctrl-j = "workspace::ToggleBottomDock";
          ctrl-w = "pane::CloseActiveItem";
          ctrl-h = "pane::ActivatePreviousItem";
          ctrl-l = "pane::ActivateNextItem";
          ctrl-shift-h = "pane::ActivateLastItem";
          # ctrl-shift-l = "pane::ActivatFirstItem"; # wat?
          ctrl-shift-o = "workspace::Open";
        };
      }
    ];

    extensions = [
      "basher"
      "dart"
      "dart"
      "dockerfile"
      "env"
      "git-firefly"
      "html"
      "ini"
      "justfile"
      "latex"
      "log"
      "make"
      "material-icon-theme"
      "nix"
      "sql"
      "strace"
      "toml"
      "typst"
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
