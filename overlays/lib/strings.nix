final: prev:
let
  inherit (final.lib.lists) repeat length;
  inherit (prev.lib.strings) concatStringsSep replaceStrings splitString;
  # inherit (final.lib.strings) wrap;
in prev.lib.strings // rec {
  # String -> [String]
  lines = splitString "\n";

  # String -> (String -> String) -> String -> String
  splitMap = splitter: f: string:
    concatStringsSep splitter (map f (splitString splitter string));

  # (String -> String) -> String -> String
  mapLines = splitMap "\n";

  # String -> Int -> String
  repeatString = string: times: concatStringsSep "" (repeat string times);

  # Replaces any occurences in a list of strings with a single replacement.
  # NOTE: This function does not support regex patterns.
  #
  # [String] -> String -> String -> String
  replaceStrings' = from: to: replaceStrings from (repeat to (length from));

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
