{ pkgs, lib, extendedLib, inputs, config, ... }: let
  inherit (lib) types mkEnableOption mkOption mdDoc;
  cfg = config.local.shell;

# NOTE:
#       This module is an over-engineered solution to a non-problem.
#       It is a fun experiment in using the Nix language to create a
#       shell alias system that organizes aliases into a tree structure,
#       with categories and subcategories and subsubcategories and so on.
#
#       It also has a lazy join function that will join a list of commands
#       with a separator, but render it in a prettier way in a documentation
#       file that you can print out and read.

  isAlias = v: builtins.isAttrs v && v ? "alias" && v ? "type";
in {
  options.local.shell = {
    aliases = let

      coerceStrToAlias = str: {
        type = " ";
        alias = [ str ];
      };

      aliasType = (types.coercedTo types.str coerceStrToAlias (types.submodule {
        options = {
          type = mkOption {
            type = types.enum [ "|" "&&" ";" " " ];
            default = ";";
            description = ''
              If the alias is a list of commands, this is the kind of separator that will be used.
            '';
          };
          alias = mkOption {
            type = types.listOf types.str;
          };
        };
      })) // {
        # NOTE: this check is necessary, because nix will recurse on types.either,
        #       and report that the option does not exist.
        #       See https://discourse.nixos.org/t/problems-with-types-oneof-and-submodules/15197
        check = v: builtins.isString v || isAlias v;
      };

      recursingAliasTreeType = types.attrsOf (types.either aliasType recursingAliasTreeType);
    in mkOption {
      type = recursingAliasTreeType;
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

    variables = mkOption {
      type = types.attrsOf types.str;
      description = "Environment variables";
      default = { };
    };

    # TODO: I want a similar system for functions at some point.
    # functions = {

    # };

    enablePackageManagerLecture = mkEnableOption "distro reminder messages, aliased to common package manager commands";
    enableAliasOverview = mkEnableOption "`aliases` command that prints out a list of all aliases" // {
      default = true;
      example = false;
    };
  };

  config = let
    sedColor =
      color:
      inputPattern:
      outputPattern:
      "-e \"s|${inputPattern}|${outputPattern.before or ""}$(tput setaf ${toString color})${outputPattern.middle}$(tput op)${outputPattern.after or ""}|g\"";

    colorRed = sedColor 1;

    colorSlashes = colorRed "/" {middle = "/";};

    # Alias type functors
    # These will help pretty print the commands
    functors = let
      inherit (lib.strings) concatStringsSep;
      inherit (extendedLib.termColors.front) blue;
    in
      {
        "|" = {
          apply = f: concatStringsSep " | " f.alias;
          stringify = f: concatStringsSep (blue "\n| ") f.alias;
        };
        "&&" = {
          apply = f: concatStringsSep " && " f.alias;
          stringify = f: concatStringsSep (blue "\n&& ") f.alias;
        };
        ";" = {
          apply = f: concatStringsSep "; " f.alias;
          stringify = f: concatStringsSep (blue ";\n  ") f.alias;
        };
        " " = {
          apply = f: concatStringsSep " " f.alias;
          stringify = f: concatStringsSep " \\\n   " f.alias;
        };
      };

    aliasTextOverview = let
      inherit (lib) stringLength length concatStringsSep replaceStrings
                    attrValues mapAttrs isAttrs remove replicate mapNullable;

      inherit (extendedLib.termColors.front) red green blue;

      # String -> String -> String
      wrap' = wrapper: str: wrapper + str + wrapper;

      # [String] -> String -> String -> String
      replaceStrings' = from: to: replaceStrings from (replicate (length from) to);

      # String -> Int -> String
      repeatString = string: times: concatStringsSep "" (replicate times string);

      # int -> String -> AttrSet -> String
      stringifyCategory = level: name: category: let
        title = "${repeatString "  " level}[${green name}]";

        commands = attrValues ((lib.flip mapAttrs) category (n: v: let
            # String
            indent = repeatString "  " level;

            # String -> String
            removeNixLinks = text: let
              maybeMatches = builtins.match "(|.*[^)])(/nix/store/.*/bin/).*" text;
              matches = mapNullable (remove "") maybeMatches;
            in
              if (maybeMatches == null)
              then text
              else replaceStrings' matches "" text;

            applyFunctor = attrset: let
              applied = functors.${attrset.type}.stringify attrset;
              indent' = indent + (repeatString " " ((stringLength " -> \"") + (stringLength n))) + " ";
            in
              replaceStrings' ["\n"] ("\n" + indent') applied;

            recurse = stringifyCategory (level + 1) n v;
          in if isAlias v
            then "${indent}  ${red n} -> ${wrap' (blue "\"") (removeNixLinks (applyFunctor v))}"
            else recurse
        ));
      in concatStringsSep "\n" ([title] ++ commands) + "\n";
    in (stringifyCategory 0 "Aliases" cfg.aliases) + "\n";

    flattenedAliases = let
      inherit (lib) mapAttrs attrValues filterAttrs isAttrs
                    isString concatStringsSep foldr;

      applyFunctor = attrset: functors.${attrset.type}.apply attrset;

      # TODO: better naming
      allAttrValuesAreStrings = attrset: let

        # [ {String} ]
        filteredAliases = [(filterAttrs (n: v: isString v) attrset)];

        # [ {String} ]
        remainingFunctors = let
          functorSet = filterAttrs (_: v: isAlias v) attrset;
          appliedFunctorSet = mapAttrs (n: v: applyFunctor v) functorSet;
        in [ appliedFunctorSet ];

        # [ {AttrSet} ]
        remainingAliasSets = attrValues (filterAttrs (_: v: isAttrs v && !isAlias v) attrset);

        # [ {String} ]
        recursedAliasSets = filteredAliases
                          ++ (remainingFunctors)
                          ++ (map allAttrValuesAreStrings remainingAliasSets);
      in foldr (a: b: a // b) {} recursedAliasSets;

    in
      allAttrValuesAreStrings cfg.aliases;

  in {
    xdg.dataFile = {
      aliases.text = aliasTextOverview;
      packageManagerLecture = lib.mkIf cfg.enablePackageManagerLecture {
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
        shellAliases = flattenedAliases;
        sessionVariables = cfg.variables;
      };
      bash = {
        shellAliases = flattenedAliases;
        sessionVariables = cfg.variables;
      };
      fish = {
        shellAliases = flattenedAliases;
        # TODO: fish does not support session variables?
        # localVariables = cfg.variables;
      };
      nushell = {
        shellAliases = flattenedAliases;
        environmentVariables = cfg.variables;
      };
    };
  };
}
