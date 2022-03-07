final: prev:
let 
  inherit (prev.lib.trivial) const;
  inherit (prev.lib.lists) range any all;
in prev.lib.lists // {
  # a -> Int -> [a]
  repeat = item: times: map (const item) (range 1 times);

  # [Bool] -> Bool
  any' = any (boolean: boolean);

  # [Bool] -> Bool
  all' = all (boolean: boolean);
}
