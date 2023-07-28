{ stdlib }:
let
  inherit (stdlib.lists) length replicate;
  inherit (stdlib.strings) concatStringsSep replaceStrings splitString;
in rec {
  # String -> [String]
  lines = splitString "\n";

  # String -> (String -> String) -> String -> String
  splitMap = splitter: f: string:
    concatStringsSep splitter (map f (splitString splitter string));

  # (String -> String) -> String -> String
  mapLines = splitMap "\n";

  # String -> Int -> String
  repeatString = string: times: concatStringsSep "" (replicate times string);

  # Replaces any occurences in a list of strings with a single replacement.
  # NOTE: This function does not support regex patterns.
  #
  # [String] -> String -> String -> String
  replaceStrings' = from: to: replaceStrings from (replicate (length from) to);

  # [String] -> String
  unlines = concatStringsSep "\n";

  # [String] -> String
  unwords = concatStringsSep " ";

  # String -> [String]
  words = builtins.split "\\s+";

  # String -> String -> String -> String
  wrap = start: end: string: start + string + end;

  # String -> String -> String
  wrap' = wrapper: wrap wrapper wrapper;
}
