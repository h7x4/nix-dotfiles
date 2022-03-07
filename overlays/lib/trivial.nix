final: prev:
let
in prev.lib.trivial // {
  # a -> b -> Either (a b)
  withDefault = default: value:
    if (value == null) then default else value;
}
