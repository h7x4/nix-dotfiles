{ pkgs, lib, config, ... }:

let mapPrefixToSet = prefix: set:
    with lib; attrsets.mapAttrs' (k: v: attrsets.nameValuePair ("${prefix}.${k}") v) set;

    vs-liveshare = pkgs.callPackage ./vscode-extensions/vsliveshare.nix {};

in
{
  programs.vscode ={
    enable = true;

    package = pkgs.vscode;
    # package = pkgs.vscodium;
    # package = pkgs.vscode-fhsWithPackages (ps: with ps; [
    #   # rustup
    #   # zlib
    #   asciidoc
    #   asciidoctor
    #   cabal2nix
    #   clang
    #   dart
    #   dotnet-sdk
    #   dotnet-sdk_3
    #   dotnet-sdk_5
    #   dotnetPackages.Nuget
    #   elm2nix
    #   elmPackages.elm
    #   flutter
    #   gcc
    #   ghc
    #   ghcid
    #   haskellPackages.Cabal_3_6_3_0
    #   maven
    #   nixfmt
    #   nixpkgs-fmt
    #   # nixpkgs-hammering
    #   nodePackages.node2nix
    #   nodePackages.npm
    #   nodePackages.sass
    #   nodePackages.typescript
    #   nodePackages.yarn
    #   nodejs
    #   plantuml
    #   python3
    #   rustc
    #   rustup
    #   sqlcheck
    #   sqlint
    #   sqlite
    #   sqlite-web
    #   xmlformat
    #   xmlstarlet
    # ]);
    # package = pkgs.vscode-fhs;

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

      java = mapPrefixToSet "java" {
        "configuration.checkProjectSettingsExclusions" = false;
        # "test.report.showAfterExecution" = "always";
        # "test.report.position" = "currentView";
        "refactor.renameFromFileExplorer" = "preview";
      };

      # sync = mapPrefixToSet "sync" {
      #   autoUpload = true;
      #   autoDownload = true;
      #   quietSync = true;
      #   gist = "86e19852a95d31a278ad1a516b40556b";
      # };

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
    java //
    python //
    svg //
    # sync //
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
      "docker.showStartPage" = false;

      "errorLens.errorBackground" = "rgba(240,0,0,0.1)";
      "errorLens.warningBackground" = "rgba(180,180,0,0.1)";

      "jupyter.askForKernelRestart" = false;

      "keyboard-quickfix.showActionNotification" = false;

      "latex-workshop.latex.autoBuild.run" = "onFileChange";
      "latex-workshop.view.pdf.viewer" = "tab";

      "liveshare.presence" = true;
      "liveshare.showInStatusBar" = "whileCollaborating";

      "liveServer.settings.port" = 5500;

      "material-icon-theme.folders.associations" = {
        ui = "layout";
        bloc = "controller";
      };

      "redhat.telemetry.enabled" = false;

      # "sonarlint.rules" = {
      #   "java:S3358" = {
      #     "level" = "off";
      #   };
      # };

      # Language overrides

      "dart.previewFlutterUiGuides" = true;
      "dart.previewFlutterUiGuidesCustomTracking" = true;
      # "dart.previewLsp" = true;

      "[dart]" = {
        "editor.defaultFormatter" = "Dart-Code.dart-code";
      };

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
      asciidoctor.asciidoctor-vscode
      bbenoist.nix
      coenraads.bracket-pair-colorizer-2
      dotjoshjohnson.xml
      elmtooling.elm-ls-vscode
      gruntfuggly.todo-tree
      haskell.haskell
      ibm.output-colorizer
      james-yu.latex-workshop
      justusadam.language-haskell
      justusadam.language-haskell
      mechatroner.rainbow-csv
      mhutchie.git-graph
      mikestead.dotenv
      ms-python.python
      ms-python.vscode-pylance
      ms-vscode-remote.remote-ssh
      naumovs.color-highlight
      pkief.material-icon-theme
      redhat.java
      redhat.vscode-yaml
      shardulm94.trailing-spaces
      usernamehw.errorlens
      vs-liveshare
      vscodevim.vim
      wholroyd.jinja
      yzhang.markdown-all-in-one
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "path-intellisense";
        publisher = "christian-kohler";
        version = "2.4.2";
        sha256 = "1a4d1n4jpdlx4r2majirnhnwlj34jc94wzbxdrih615176hadxvc";
      }
      {
        name = "vscode-html-css";
        publisher = "ecmel";
        version = "1.10.2";
        sha256 = "0qzh7fwgadcahxx8hz1sbfz9lzi81iv4xiidvfm3sahyl9s6pyg1";
      }
      {
        name = "vscode-drawio";
        publisher = "hediet";
        version = "1.6.3";
        sha256 = "0r4qrw1l8s8sfgxj4wvkzamd3yc1h1l60r3kkc1g9afkikmnbr5w";
      }
      {
        name = "language-x86-64-assembly";
        publisher = "13xforever";
        version = "3.0.0";
        sha256 = "0lxg58hgdl4d96yjgrcy2dbacxsc3wz4navz23xaxcx1bgl1i2y0";
      }
      {
        name = "monokai-st3";
        publisher = "AndreyVolosovich";
        version = "0.2.0";
        sha256 = "1rvz5hlrfshy9laybxzvrdklx328s13j0lb8ljbda9zkadi3wcad";
      }
      # {
      #   name = "nix-env-selector";
      #   publisher = "arrterian";
      #   version = "1.0.7";
      #   sha256 = "0mralimyzhyp4x9q98x3ck64ifbjqdp8cxcami7clvdvkmf8hxhf";
      # }
      {
        name = "vscode-JS-CSS-HTML-formatter";
        publisher = "lonefy";
        version = "0.2.3";
        sha256 = "06vivclp58wzmqcx6s6pl8ndqina7p995dr59aj9fk65xihkaagy";
      }
      {
        name = "indent-rainbow";
        publisher = "oderwat";
        version = "8.2.2";
        sha256 = "1xxljwh66f21fzmhw8icrmxxmfww1s67kf5ja65a8qb1x1rhjjgf";
      }
      {
        name = "vscode-css-peek";
        publisher = "pranaygp";
        version = "4.2.0";
        sha256 = "0dpkp3xs8jd826h2aa9xlfilsj4yv8q6r9cs350ljrpcyj7wrlpq";
      }
      {
        name = "LiveServer";
        publisher = "ritwickdey";
        version = "5.6.1";
        sha256 = "077arf3hsn1yb8xdhlrax5gf93ljww78irv4gm8ffmsqvcr1kws0";
      }
      {
        name = "background";
        publisher = "shalldie";
        version = "1.1.29";
        sha256 = "1x3k8pmzp186bcgga3wg6y86waxrcsi5cnwaxfmifqgn87jp2vqq";
      }
      {
        name = "comment-divider";
        publisher = "stackbreak";
        version = "0.4.0";
        sha256 = "1qcj2lngcv1sc7jri70ilkkrcx34wn8f4sqwk4dlgrribw6nvj1g";
      }
      {
        name = "lorem-ipsum";
        publisher = "Tyriar";
        version = "1.3.0";
        sha256 = "03jas413ivahfpxrlc5qif35nd67m1nmwx8p8dj1fpv04s6fdigb";
      }
      {
        name = "vscode-svgviewer";
        publisher = "cssho";
        version = "2.0.0";
        sha256 = "06swlqiv3gc7plcbmzz795y6zwpxsdhg79k1n3jj6qngfwnv2p6z";
      }
      {
        name = "arm";
        publisher = "dan-c-underwood";
        version = "1.5.2";
        sha256 = "0x31wmd6m1gzm0sfi5xjsa38jr043qq9kgykw3b52hcma7ww8ky3";
      }
      {
        name = "dart-code";
        publisher = "Dart-Code";
        version = "3.28.0";
        sha256 = "0ppzv0cs4b559m4nvbfik2m63hs10g5idrc5j3pkgdjm14n1jiwv";
      }
      {
        name = "comment-anchors";
        publisher = "ExodiusStudios";
        version = "1.9.6";
        sha256 = "1zgvgf6zq1ny3v8b9jjp4j3n27qmiz45g23ljaim92g6hni38wvv";
      }
      {
        name = "bloc";
        publisher = "FelixAngelov";
        version = "6.2.0";
        sha256 = "0rr00pfcpjk17plzmmaqr0znj3k1qd0m2rh15c9894fifdyy69fx";
      }
      {
        name = "vscode-test-explorer";
        publisher = "hbenl";
        version = "2.21.1";
        sha256 = "022lnkq278ic0h9ggpqcwb3x3ivpcqjimhgirixznq0zvwyrwz3w";
      }
      {
        name = "haskell-linter";
        publisher = "hoovercj";
        version = "0.0.6";
        sha256 = "0fb71cbjx1pyrjhi5ak29wj23b874b5hqjbh68njs61vkr3jlf1j";
      }
      {
        name = "plantuml";
        publisher = "jebbs";
        version = "2.16.1";
        sha256 = "17gkrai7fdhrq0q1zip4wn7j4qx9vbbirx3n68silb34wh0dbydk";
      }
      {
        name = "vscode-gutter-preview";
        publisher = "kisstkondoros";
        version = "0.29.0";
        sha256 = "00vibv9xmhwaqiqzp0y2c246pqiqfjsw4bqx4vcdd67pz1wnqhg1";
      }
      {
        name = "vscode-JS-CSS-HTML-formatter";
        publisher = "lonefy";
        version = "0.2.3";
        sha256 = "06vivclp58wzmqcx6s6pl8ndqina7p995dr59aj9fk65xihkaagy";
      }
      {
        name = "test-adapter-converter";
        publisher = "ms-vscode";
        version = "0.1.4";
        sha256 = "02b04756kfk640hri1xw0p6kwjxwp8d2hpmca0iysfivfcmm1bqn";
      }
      {
        name = "awesome-flutter-snippets";
        publisher = "Nash";
        version = "3.0.2";
        sha256 = "009z6k719w0sypzsk53wiard3j3d8bq9b0g9s82vw3wc4jvkc3hr";
      }
      {
        name = "indent-rainbow";
        publisher = "oderwat";
        version = "8.2.2";
        sha256 = "1xxljwh66f21fzmhw8icrmxxmfww1s67kf5ja65a8qb1x1rhjjgf";
      }
      {
        name = "vscode-xml";
        publisher = "redhat";
        version = "0.18.1";
        sha256 = "006fjcr8s3rsznqgpp13cmvw8k94cfpr24r3rp019jaj5as3l1ck";
      }
      {
        name = "comment-divider";
        publisher = "stackbreak";
        version = "0.4.0";
        sha256 = "1qcj2lngcv1sc7jri70ilkkrcx34wn8f4sqwk4dlgrribw6nvj1g";
      }
      {
        name = "addDocComments";
        publisher = "stevencl";
        version = "0.0.8";
        sha256 = "08572fhn6ilfbx8zwn849ab3npyfkh9m5mk2br6sii601s9k5vrk";
      }
      {
        name = "vscodeintellicode";
        publisher = "VisualStudioExptTeam";
        version = "1.2.14";
        sha256 = "1j72v6grwasqk34m1jy3d6w3fgrw0dnsv7v17wca8baxrvgqsm6g";
      }
      {
        name = "vscode-java-debug";
        publisher = "vscjava";
        version = "0.36.0";
        sha256 = "1p9mymbf8sn39k44350zf3zwl29fhcwxfsqxr7841ch1qz88w9r8";
      }
      {
        name = "vscode-java-dependency";
        publisher = "vscjava";
        version = "0.18.8";
        sha256 = "1yjzgf96kqm09qlhxpa249fqb2b5wpzw9k53sgr8jx8sfx5qn95b";
      }
      {
        name = "vscode-java-pack";
        publisher = "vscjava";
        version = "0.18.6";
        sha256 = "095jdvvv4m8s2ymnrsq0ay7afqff5brgn6waknjfyy97qb3mzxj8";
      }
      {
        name = "vscode-java-test";
        publisher = "vscjava";
        version = "0.32.0";
        sha256 = "0lq6daz228ipzls88y09zbdsv9n6backs5bddpdam628rs99qvn3";
      }
      {
        name = "vscode-maven";
        publisher = "vscjava";
        version = "0.34.1";
        sha256 = "1mnlvnl2lg8fijxx4a6rqjix9k2j82js8kn8da7kjf4wh0ksdgvd";
      }
      {
        name = "markdown-all-in-one";
        publisher = "yzhang";
        version = "3.4.0";
        sha256 = "0ihfrsg2sc8d441a2lkc453zbw1jcpadmmkbkaf42x9b9cipd5qb";
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
