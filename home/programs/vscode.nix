{ pkgs, lib, config, ... }:

let mapPrefixToSet = prefix: set:
    with lib; attrsets.mapAttrs' (k: v: attrsets.nameValuePair ("${prefix}.${k}") v) set;

    # vs-liveshare = pkgs.callPackage ./vscode-extensions/vsliveshare.nix {};

in
{
  programs.vscode ={
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
        detectIndentation = false;
        tabCompletion = "onlySnippets";
        snippetSuggestions = "top";
        cursorBlinking = "smooth";
        cursorSmoothCaretAnimation = true;
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
        hideTabs = false;
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
      "emmet.triggerExpansionOnTab" = true;
      "explorer.confirmDragAndDrop" = false;
      "git.allowForcePush" = true;
      "git.autofetch" = true;
      "telemetry.telemetryLevel" = "off";
      "terminal.integrated.fontSize" = 14;
      "vsintellicode.modify.editor.suggestSelection" = "automaticallyOverrodeDefaultValue";
      "window.zoomLevel" = 2;

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
      # vs-liveshare
      vscodevim.vim
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "monokai-st3";
        publisher = "AndreyVolosovich";
        version = "0.2.0";
        sha256 = "1rvz5hlrfshy9laybxzvrdklx328s13j0lb8ljbda9zkadi3wcad";
      }
      {
        name = "vscode-svgviewer";
        publisher = "cssho";
        version = "2.0.0";
        sha256 = "06swlqiv3gc7plcbmzz795y6zwpxsdhg79k1n3jj6qngfwnv2p6z";
      }
      {
        name = "comment-anchors";
        publisher = "ExodiusStudios";
        version = "1.9.6";
        sha256 = "1zgvgf6zq1ny3v8b9jjp4j3n27qmiz45g23ljaim92g6hni38wvv";
      }
      {
        name = "vscode-test-explorer";
        publisher = "hbenl";
        version = "2.21.1";
        sha256 = "022lnkq278ic0h9ggpqcwb3x3ivpcqjimhgirixznq0zvwyrwz3w";
      }
      {
        name = "vscode-gutter-preview";
        publisher = "kisstkondoros";
        version = "0.29.0";
        sha256 = "00vibv9xmhwaqiqzp0y2c246pqiqfjsw4bqx4vcdd67pz1wnqhg1";
      }
      {
        name = "test-adapter-converter";
        publisher = "ms-vscode";
        version = "0.1.4";
        sha256 = "02b04756kfk640hri1xw0p6kwjxwp8d2hpmca0iysfivfcmm1bqn";
      }
      # {
      #   name = "indent-rainbow";
      #   publisher = "oderwat";
      #   version = "8.2.2";
      #   sha256 = "1xxljwh66f21fzmhw8icrmxxmfww1s67kf5ja65a8qb1x1rhjjgf";
      # }
      {
        name = "vscodeintellicode";
        publisher = "VisualStudioExptTeam";
        version = "1.2.14";
        sha256 = "1j72v6grwasqk34m1jy3d6w3fgrw0dnsv7v17wca8baxrvgqsm6g";
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
