{ config, pkgs, lib, extendedLib, ... }: let
  cfg = config.local.shell;

  shellAliasesFormat = let
    formatLib = {
      functors = let
        inherit (extendedLib.termColors.front) blue;
      in
        {
          "|" = {
            apply = f: lib.concatStringsSep " | " f.alias;
            stringify = f: lib.concatStringsSep (blue "\n| ") f.alias;
          };
          "&&" = {
            apply = f: lib.concatStringsSep " && " f.alias;
            stringify = f: lib.concatStringsSep (blue "\n&& ") f.alias;
          };
          ";" = {
            apply = f: lib.concatStringsSep "; " f.alias;
            stringify = f: lib.concatStringsSep (blue ";\n  ") f.alias;
          };
          " " = {
            apply = f: lib.concatStringsSep " " f.alias;
            stringify = f: lib.concatStringsSep " \\\n   " f.alias;
          };
        };

      isAlias = v: builtins.isAttrs v && v ? "alias" && v ? "type";
    };
  in {
    lib = formatLib;

    type = let
      rawAliasType = lib.types.submodule {
        options = {
          type = lib.mkOption {
            description = "If the alias is a list of commands, this is the kind of separator that will be used.";
            type = lib.types.enum (lib.attrNames formatLib.functors);
            default = ";";
            example = "&&";
          };
          alias = lib.mkOption {
            description = "List of commands that will be concatenated together.";
            type = with lib.types; listOf str;
            example = [
              "ls"
              "grep nix"
            ];
          };
        };
      };

      coercedAliasType = with lib.types; let
        coerce = str: {
          type = " ";
          alias = [ str ];
        };
      in (coercedTo str coerce rawAliasType) // {
        check = v: builtins.isString v || formatLib.isAlias v;
      };

      aliasTreeType = with lib.types; attrsOf (either coercedAliasType aliasTreeType);
    in aliasTreeType;

    # Alias Tree -> { :: Alias }
    generateAttrs = let
      inherit (lib) mapAttrs attrValues filterAttrs isAttrs
                    isString concatStringsSep foldr;

      applyFunctor = attrset: formatLib.functors.${attrset.type}.apply attrset;

      # TODO: better naming
      allAttrValuesAreStrings = attrset: let

        # [ {String} ]
        filteredAliases = [(filterAttrs (_: isString) attrset)];

        # [ {String} ]
        remainingFunctors = let
          functorSet = filterAttrs (_: formatLib.isAlias) attrset;
          appliedFunctorSet = mapAttrs (_: applyFunctor) functorSet;
        in [ appliedFunctorSet ];

        # [ {AttrSet} ]
        remainingAliasSets = attrValues (filterAttrs (_: v: isAttrs v && !formatLib.isAlias v) attrset);

        # [ {String} ]
        recursedAliasSets = filteredAliases
                          ++ (remainingFunctors)
                          ++ (map allAttrValuesAreStrings remainingAliasSets);
      in foldr (a: b: a // b) {} recursedAliasSets;

    in
      allAttrValuesAreStrings;

    # TODO:
    # generateAttrs = pipe [
      # collect leave nodes
      # map apply functor
    # ]

    # Alias Tree -> String
    generateText = aliases: let
      inherit (extendedLib.termColors.front) red green blue;

      # String -> Alias -> String
      stringifyAlias = aliasName: alias: let
        # String -> String
        removeNixLinks = text: let
          maybeMatches = lib.match "(|.*[^)])(/nix/store/.*/bin/).*" text;
          matches = lib.mapNullable (lib.remove "") maybeMatches;
        in
          if (maybeMatches == null)
          then text
          else lib.replaceStrings matches (lib.replicate (lib.length matches) "") text;

        # Alias -> String
        applyFunctor = attrset: let
          applied = formatLib.functors.${attrset.type}.stringify attrset;
          indent' = lib.strings.replicate (lib.stringLength "${aliasName} -> ") " ";
        in
          lib.replaceStrings ["\n"] [("\n" + indent')] applied;
      in "${red aliasName} -> ${blue "\""}${removeNixLinks (applyFunctor alias)}${blue "\""}";

      # String -> String
      indent = x: lib.pipe x [
        (x: "\n" + x)
        (lib.replaceStrings ["\n"] [("\n" + (lib.strings.replicate 2 " "))])
        (lib.removePrefix "\n")
      ];

      # String -> { :: Alias | Category } -> String
      stringifyCategory = categoryName: category: lib.pipe category [
        (category: let
          aliases = lib.filterAttrs (_: formatLib.isAlias) category;
        in {
          inherit aliases;
          subcategories = lib.removeAttrs category (lib.attrNames aliases);
        })
        ({ aliases, subcategories }: {
          aliases = lib.mapAttrsToList stringifyAlias aliases;
          subcategories = lib.mapAttrsToList stringifyCategory subcategories;
        })
        ({ aliases, subcategories }:
          lib.concatStringsSep "\n" (lib.filter (x: lib.trim x != "") [
            "[${green categoryName}]"
            (indent (lib.concatStringsSep "\n" aliases) + "\n")
            (indent (lib.concatStringsSep "\n" subcategories) + "\n")
          ])
        )
      ];
    in (stringifyCategory "Aliases" aliases);
  };
in {
  options.local.shell = {
    aliases = lib.mkOption {
      # TODO: freeformType
      type = shellAliasesFormat.type;
      description = "A tree of aliases";
      default = { };
      example = {
        "My first alias category" = {
          cmd1 = ''echo "hello world"'';
          cmd2 = {
            type = "|";
            alias = [
              "ls -la"
              "grep -i hello"
            ];
          };
        };

        "My second alias category" = {
          cmd1 = {
            type = "&&";
            alias = [
              ''echo "hello world"''
              ''echo "goodbye world"''
            ];
          };
        };
      };
    };

    variables = lib.mkOption {
      type = with lib.types; attrsOf str;
      description = "Environment variables";
      default = { };
    };

    # TODO: I want a similar system for functions at some point.
    # functions = {

    # };

    enablePackageManagerLecture = lib.mkEnableOption "distro reminder messages, aliased to common package manager commands";

    enableAliasOverview = lib.mkEnableOption "`aliases` command that prints out a list of all aliases" // {
      default = true;
      example = false;
    };
  };

  config = {
    xdg.dataFile = {
      "aliases".text = shellAliasesFormat.generateText cfg.aliases;

      "packageManagerLecture" = lib.mkIf cfg.enablePackageManagerLecture {
        target = "package-manager.lecture";
        text = let
          inherit (extendedLib.termColors.front) red blue;
        in lib.concatStringsSep "\n" [
          ((red "This package manager is not installed on ") + (blue "NixOS") + (red "."))
          ((red "Either use ") + ("\"nix-env -i\"") + (red " or install it through a configuration file."))
          ""
        ];
      };
    };

    local.shell.aliases."Package Managers" = lib.mkIf cfg.enablePackageManagerLecture (let
        inherit (lib.attrsets) nameValuePair listToAttrs;

        packageManagers = [
          "apt"
          "dpkg"
          "flatpak"
          "pacman"
          "pamac"
          "paru"
          "rpm"
          "snap"
          "xbps"
          "yay"
          "yum"
        ];

        command = "${pkgs.coreutils}/bin/cat $HOME/${config.xdg.dataFile.packageManagerLecture.target}";
        nameValuePairs = map (pm: nameValuePair pm command) packageManagers;
      in listToAttrs nameValuePairs);

    local.shell.aliases.aliases = lib.mkIf cfg.enableAliasOverview
      "${pkgs.coreutils}/bin/cat $HOME/${config.xdg.dataFile.aliases.target}";

    programs = {
      zsh = {
        shellAliases = shellAliasesFormat.generateAttrs cfg.aliases;
        sessionVariables = cfg.variables;
      };
      bash = {
        shellAliases = shellAliasesFormat.generateAttrs cfg.aliases;
        sessionVariables = cfg.variables;
      };
      fish = {
        shellAliases = shellAliasesFormat.generateAttrs cfg.aliases;
        # TODO: fish does not support session variables?
        # localVariables = cfg.variables;
      };
      nushell = {
        shellAliases = shellAliasesFormat.generateAttrs cfg.aliases;
        environmentVariables = cfg.variables;
      };
    };
  };
}
