{ config, lib, pkgs, unstable-pkgs, ... }:
let
  cfg = config.programs.zed-editor;
in
{
  programs.zed-editor = {
    package = unstable-pkgs.zed-editor;

    extraPackages = with pkgs; [
      gopls
      groovy
      nixd
      pyright
    ];

    userSettings = {
      auto_update = false;

      load_direnv = "shell_hook";
      base_keymap = "VSCode";

      autosave = "off";
      format_on_save = "off";
      remove_trailing_whitespace_on_save = true;
      show_whitespaces = "trailing";

      tab_size = 2;

      ui_font_family = "Noto Sans";
      ui_font_size = 18;

      buffer_font_family = "Fira Code";
      buffer_font_size = 16;

      terminal.font_family = "Fira Code";
      terminal.font_size = 15;

      vertical_scroll_margin = 4;
      scroll_beyond_last_line = "vertical_scroll_margin";
      sticky_scroll.enabled = true;

      file_types = {
        "Groovy" = [ "Jenkinsfile*" ];
        "Dockerfile" = [ "Dockerfile*" ];
        "JSONC" = [ "json5" ];
      };

      tabs = {
        git_status = true;
        file_icons = true;
        show_close_button = "hover";
        show_diagnostics = "errors";
      };

      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      diagnostics = {
        include_warnings = true;
        inline.enabled = true;
      };

      search = {
        case_sensitive = true;
        regex = true;
      };

      relative_line_numbers = "enabled";

      vim_mode = true;
      vim = {
        toggle_relative_line_numbers = true;
      };

      theme = "Monokai-og";

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

      git.inline_blame.enabled = false;

      collaboration_panel.button = false;
      project_panel.entry_spacing = "standard";
      title_bar.show_branch_icon = true;

      preview_tabs.enabled = false;

      indent_guides = {
        enabled = true;
        coloring = "indent_aware";
      };

      colorize_brackets = true;

      node = {
          path = lib.getExe pkgs.nodejs;
          npm_path = lib.getExe' pkgs.nodejs "npm";
      };

      features.edit_prediction_provider = "copilot";

      languages = {
        Nix = {
          tab_size = 2;
          format_on_save = "off";
          language_servers = [ "nixd" "!nil" ];
        };
        Python = {
          language_servers = [
            "ty"
            "ruff"
            "!basedpyright"
          ];
          format_on_save = "off";
          formatter = [
            # {
            #   code_actions = {
            #     "source.organizeImports.ruff" = true;
            #     "source.fixAll.ruff" = true;
            #   };
            # }
            {
              language_server.name = "ruff";
            }
          ];
        };
      };

      lsp = {
        rust-analyzer = { };
        nix = { };
        nixd = { };
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
      "assembly-syntax"
      "basher"
      "comment"
      "dart"
      "dart"
      "dockerfile"
      "env"
      "git-firefly"
      "graphql"
      "groovy"
      "html"
      "ini"
      "just"
      "latex"
      "live-server"
      "log"
      "make"
      "material-icon-theme"
      "mermaid"
      "monokai-og"
      "neocmake"
      "nix"
      "ocaml"
      "rainbow-csv"
      "ruff"
      "sql"
      "strace"
      "toml"
      "typst"
    ];
  };

  programs.zsh.initContent = lib.mkIf cfg.enable ''
    if [[ "$ZED_TERM" == "true" && -n "$TMUX_PANE" ]]; then
      unset TMUX_PANE
    fi
  '';
}
