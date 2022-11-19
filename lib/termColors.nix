{ stdlib, strings }:
let
  inherit (strings) wrap;
  inherit (stdlib.attrsets) mapAttrs' nameValuePair;
in rec {
  # String
  escapeCharacter = "";

  # String -> String
  escapeColor = color: "${escapeCharacter}[${color}m";

  # String
  resetCharacter = escapeColor "0";

  # String -> String -> String
  wrapWithColor = color: wrap color resetCharacter;

  # String -> String -> String
  wrapWithColor' = color: wrap (escapeColor color) resetCharacter;

  # AttrSet{String}
  colorMappings = {
    "black" = "0";
    "red" = "1";
    "green" = "2";
    "yellow" = "3";
    "blue" = "4";
    "magenta" = "5";
    "cyan" = "6";
    "white" = "7";
  };

  # AttrSet{(String -> String)}
  front = let
    # AttrSet{(String -> String)}
    names = mapAttrs' (n: v: nameValuePair n (wrapWithColor' ("3" + v))) colorMappings;

    # AttrSet{(String -> String)}
    numbers = mapAttrs' (n: v: nameValuePair v (wrapWithColor' ("3" + v))) colorMappings;
  in names // numbers;
  back = let
    # AttrSet{(String -> String)}
    names = mapAttrs' (n: v: nameValuePair n (wrapWithColor' ("4" + v))) colorMappings;

    # AttrSet{(String -> String)}
    numbers = mapAttrs' (n: v: nameValuePair v (wrapWithColor' ("4" + v))) colorMappings;
  in names // numbers;
}
