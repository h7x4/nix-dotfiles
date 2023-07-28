{ stdlib }:
let 
  inherit (stdlib.trivial) const;
  inherit (stdlib.lists) range any all;
in {
  # [Bool] -> Bool
  any' = any (boolean: boolean);

  # [Bool] -> Bool
  all' = all (boolean: boolean);
}
