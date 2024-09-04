{ pkgs, lib, config, ... }:
let
  cfg = config.programs.vscode;

  mapPrefixToSet = prefix: set:
    with lib; attrsets.mapAttrs' (k: v: attrsets.nameValuePair ("${prefix}.${k}") v) set;

  configDir = {
    "vscode" = "Code";
    "vscode-insiders" = "Code - Insiders";
    "vscodium" = "VSCodium";
  }.${cfg.package.pname};
  userDir = "${config.xdg.configHome}/${configDir}/User";
  configFilePath = "${userDir}/settings.json";
in
{
  imports = [
    ./auto-update-extensions.nix
    # ./extensions
  ];

  home.file.${configFilePath} = {
    target = "${configFilePath}.ro";
    onChange = ''install -m660 $(realpath "${configFilePath}.ro") "${configFilePath}"'';
  };

  programs.vscode = {
    enable = true;

    package = pkgs.vscode;

    userSettings = let
      editor = mapPrefixToSet "editor" {
        fontFamily = "Fira Code";
        fontLigatures = true;
        lineNumbers = "relative";
        mouseWheelZoom = false;
        fontSize = 14;
        "minimap.enabled" = false;
        tabSize = 2;
        insertSpaces = true;
        "inlineSuggest.enabled" = true;
        "inlayHints.enabled" = "offUnlessPressed";
        detectIndentation = false;
        tabCompletion = "onlySnippets";
        snippetSuggestions = "top";
        cursorBlinking = "smooth";
        cursorSmoothCaretAnimation = "on";
        multiCursorModifier = "ctrlCmd";
        suggestSelection = "first";
        cursorStyle = "line";
        wordSeparators = "/\\()\"':,.;<>~!@#$%^&*|+=[]{}`?-";
        wordWrap = "off";
        # "bracketPairColorization.enabled" = true;
      };

      zen = mapPrefixToSet "zenMode" {
        centerLayout = true;
        hideStatusBar = false;
        hideLineNumbers = false;
      };

      vim = mapPrefixToSet "vim" {
        useSystemClipboard = true;
        "statusBarColorControl" = true;
        "statusBarColors.insert" = "#20ff00";
        "statusBarColors.normal" = "#1D1E20";
        "statusBarColors.visual" = "#00ffff";
        "statusBarColors.replace" = "#ff002b";
        handleKeys = {
          "<C-d>" = true;
          "<C-j>" = false;
          "<C-b>" = false;
          "<C-k>" = false;
          "<C-w>" = false;
          "<C-n>" = false;
          "<A-o>" = true;
        };
      };

      workbench = mapPrefixToSet "workbench" {
        "settings.enableNaturalLanguageSearch" = false;
        enableExperiments = false;
        iconTheme = "material-icon-theme";
        colorTheme = "Monokai ST3";
        colorCustomizations = {
          "statusBar.background" = "#1D1E20";
          "statusBar.noFolderBackground" = "#1D1E20";
          "statusBar.debuggingBackground" = "#1D1E20";
          "[Monokai ST3]" = {
            "editor.foreground" = "#ffffff";
          };
        };
        editorAssociations = {
          "*.pdf" = "default";
          "*.ipynb" = "jupyter.notebook.ipynb";
        };
      };

      python = mapPrefixToSet "python" {
        "analysis.completeFunctionParens" = true;
        "formatting.provider" = "yapf";
        "formatting.yapfArgs" = [
          "--style={based_on_style: pep8, indent_width: 2}"
        ];
        "autoComplete.addBrackets" = true;
        languageServer = "Pylance";
      };

      svg = mapPrefixToSet "svgviewer" {
        transparencygrid = true;
        enableautopreview = true;
        previewcolumn = "Beside";
        showzoominout = true;
      };

      indentRainbow = mapPrefixToSet "indentRainbow" {
        errorColor= "rgb(255, 0, 0)";
        colors = [ # http://colrd.com/palette/38436/
          "rgba(26, 19, 52, 0.1)"
          "rgba(1, 84, 90, 0.1)"
          "rgba(3, 195, 131, 0.1)"
          "rgba(251, 191, 69, 0.1)"
          "rgba(237, 3, 69, 0.1)"
          "rgba(113, 1, 98, 0.1)"
          "rgba(2, 44, 125, 0.1)"
          "rgba(38, 41, 74, 0.1)"
          "rgba(1, 115, 81, 0.1)"
          "rgba(170, 217, 98, 0.1)"
          "rgba(239, 106, 50, 0.1)"
          "rgba(161, 42, 94, 0.1)"
        ];
        ignoreErrorLanguages = [
          "markdown"
          "haskell"
          "elm"
          "fsharp"
          "java"
        ];
      };

    in
    editor //
    indentRainbow //
    python //
    svg //
    workbench //
    vim // # This needs to come after workbench because of setting ordering
    zen //
    {
      "extensions.autoCheckUpdates" = false;
      "extensions.autoUpdate" = false;
      "diffEditor.ignoreTrimWhitespace" = false;
      "diffEditor.hideUnchangedRegions" = "enabled";
      "emmet.triggerExpansionOnTab" = true;
      "explorer.confirmDragAndDrop" = false;
      "git.allowForcePush" = true;
      "git.autofetch" = true;
      "telemetry.telemetryLevel" = "off";
      "terminal.integrated.fontSize" = 14;
      "vsintellicode.modify.editor.suggestSelection" = "automaticallyOverrodeDefaultValue";
      "window.zoomLevel" = 1;

      "search.exclude" = {
        "**/node_modules" = true;
        "**/bower_components" = true;
        "**/*.code-search" = true;
        "**/.direnv/" = true;
      };

      # This setting does not support language overrides
      "files.exclude" = {
        # Java
        "**/.classpath" = true;
        "**/.project" = true;
        "**/.settings" = true;
        "**/.factorypath" = true;
      };

      # Extensions

      "bracket-pair-colorizer-2.colorMode" = "Consecutive";
      "bracket-pair-colorizer-2.forceIterationColorCycle" = true;
      "bracket-pair-colorizer-2.colors" = [
        "#fff200"
        "#3d33ff"
        "#ff57d5"
        "#00ff11"
        "#ff8400"
        "#ff0030"
      ];

      "errorLens.errorBackground" = "rgba(240,0,0,0.1)";
      "errorLens.warningBackground" = "rgba(180,180,0,0.1)";

      "keyboard-quickfix.showActionNotification" = false;

      "liveshare.presence" = true;
      "liveshare.showInStatusBar" = "whileCollaborating";

      "liveServer.settings.port" = 5500;

      "material-icon-theme.folders.associations" = {
        ui = "layout";
        bloc = "controller";
      };

      "redhat.telemetry.enabled" = false;

      "[html]" = {
        "editor.formatOnSave" = false;
        "editor.defaultFormatter" = "vscode.html-language-features";
      };

      "[javascript]" = {
        "editor.formatOnSave" = false;
        "editor.defaultFormatter" = "vscode.typescript-language-features";
      };

      "[json]" = {
        "editor.formatOnSave" = true;
        "editor.defaultFormatter" = "vscode.json-language-features";
      };

      "[jsonc]" = {
        "editor.defaultFormatter" = "vscode.json-language-features";
      };
    };

    keybindings = [
      {
        key = "ctrl+[Period]";
        command = "keyboard-quickfix.openQuickFix";
        when = "editorHasCodeActionsProvider && editorTextFocus && !editorReadonly";
      }

      {
        key = "alt+k";
        command = "selectPrevSuggestion";
        when = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus";
      }

      {
        key = "alt+j";
        command = "selectNextSuggestion";
        when = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus";
      }

      {
        key = "alt+k";
        command = "editor.action.moveLinesUpAction";
        when = "editorTextFocus && !editorReadonly && !suggestWidgetVisible";
      }

      {
        key = "alt+j";
        command = "editor.action.moveLinesDownAction";
        when = "editorTextFocus && !editorReadonly && !suggestWidgetVisible";
      }

      {
        key = "alt+j";
        command = "workbench.action.quickOpenNavigateNext";
        when = "inQuickOpen";
      }

      {
        key = "alt+k";
        command = "workbench.action.quickOpenNavigatePrevious";
        when = "inQuickOpen";
      }

      {
        key = "alt+f";
        command = "editor.action.formatDocument";
        when = "editorTextFocus && !editorReadonly";
      }

      {
        key = "alt+o";
        command = "editor.action.insertLineAfter";
        when = "textInputFocus && !editorReadonly";
      }

      {
        key = "alt+shift+o";
        command = "editor.action.insertLineBefore";
        when = "textInputFocus && !editorReadonly";
      }
    ];

    extensions = with pkgs.vscode-extensions; [
      # WakaTime.vscode-wakatime
      # dotjoshjohnson.xml
      # eamodio.gitlens
      # jock.svg
      # ms-azuretools.vscode-docker
      # ms-toolsai.jupyter
      # ms-vscode-remote.remote-ssh
      # ms-vsliveshare.vsliveshare
      bbenoist.nix
      christian-kohler.path-intellisense
      # coenraads.bracket-pair-colorizer-2
      haskell.haskell
      justusadam.language-haskell
      justusadam.language-haskell
      mechatroner.rainbow-csv
      mhutchie.git-graph
      ms-python.python
      ms-python.vscode-pylance
      ms-vscode-remote.remote-ssh
      naumovs.color-highlight
      oderwat.indent-rainbow
      pkief.material-icon-theme
      redhat.vscode-yaml
      shardulm94.trailing-spaces
      usernamehw.errorlens
      rust-lang.rust-analyzer
      mkhl.direnv
      waderyan.gitblame
      vscodevim.vim
      hbenl.vscode-test-explorer
      # vitaliymaz.vscode-svg-previewer
      ms-vscode.test-adapter-converter
      visualstudioexptteam.vscodeintellicode
      tamasfe.even-better-toml
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "monokai-st3";
        publisher = "AndreyVolosovich";
        version = "0.2.0";
        sha256 = "1rvz5hlrfshy9laybxzvrdklx328s13j0lb8ljbda9zkadi3wcad";
      }
      {
        name = "comment-anchors";
        publisher = "ExodiusStudios";
        version = "1.10.4";
        sha256 = "sha256-FvfjPpQsgCsnY1BylhLCM/qDQChf9/iTr3cKkCGfMVI=";
      }
      {
        name = "vscode-gutter-preview";
        publisher = "kisstkondoros";
        version = "0.31.2";
        sha256 = "sha256-2/RvDSsVL06UmNG9HchXaJMJ4FYtnpuJ2Bn53JVv1t8=";
      }
      {
        name = "keyboard-quickfix";
        publisher = "pascalsenn";
        version = "0.0.6";
        sha256 = "BK7ND6gtRVEitxaokJHmQ5rvSOgssVz+s9dktGQnY6M=";
      }
    ];
  };
}
