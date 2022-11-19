{ stdlib }:
let 
  inherit (stdlib.trivial) const;
  inherit (stdlib.lists) range any all;
in {
  # a -> Int -> [a]
  repeat = item: times: map (const item) (range 1 times);

  # [Bool] -> Bool
  any' = any (boolean: boolean);

  # [Bool] -> Bool
  all' = all (boolean: boolean);
}
