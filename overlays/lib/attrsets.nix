final: prev:
let
  inherit (prev.lib.attrsets) mapAttrs isAttrs filterAttrs listToAttrs nameValuePair attrNames mapAttrsToList;
  inherit (prev.lib.lists) foldr imap0 imap1;
in prev.lib.attrsets // rec {
  # a -> [String] -> AttrSet{a}
  mapToAttrsWithConst = constant: items:
    listToAttrs (map (name: nameValuePair name constant) items);

  # [AttrSet] -> AttrSet
  concatAttrs = foldr (a: b: a // b) {};

  # (Int -> String -> a -> a) -> AttrSet -> AttrSet
  imap0Attrs = f: set:
    listToAttrs (imap0 (i: attr: nameValuePair attr (f i attr set.${attr})) (attrNames set));

  # (Int -> String -> a -> a) -> AttrSet -> AttrSet
  imap1Attrs = f: set:
    listToAttrs (imap1 (i: attr: nameValuePair attr (f i attr set.${attr})) (attrNames set));

  # (Int -> String -> a -> nameValuePair) -> AttrSet -> AttrSet
  imap0Attrs' = f: set:
    listToAttrs (imap0 (i: attr: f i attr set.${attr}) (attrNames set));

  # (Int -> String -> a -> nameValuePair) -> AttrSet -> AttrSet
  imap1Attrs' = f: set:
    listToAttrs (imap1 (i: attr: f i attr set.${attr}) (attrNames set));

  # AttrSet -> AttrSet
  recursivelyFlatten = set: let
    shouldRecurse = filterAttrs (n: v: isAttrs v) set;
    shouldNotRecurse = filterAttrs (n: v: !(isAttrs v)) set;
    recursedAttrs = mapAttrsToList (n: v: recursivelyFlatten v) shouldRecurse;
  in
    concatAttrs ([shouldNotRecurse] ++ recursedAttrs);

  # Takes in a predicate which decides whether or not to recurse further. (true -> recurse)
  # This will let you recurse until you recurse until you hit attrsets with a special meaning
  # that you would like to handle after flattening.
  # It will also stop at everything other than an attribute set.
  #
  # (a -> Bool) -> AttrSet -> AttrSet
  recursivelyFlattenUntil = pred: set: let
    shouldRecurse = filterAttrs (n: v: isAttrs v && !(pred v)) set;
    shouldNotRecurse = filterAttrs (n: v: !(isAttrs v) || pred v) set;
    recursedAttrs = mapAttrsToList (n: v: recursivelyFlattenUntil pred v) shouldRecurse;
  in
    concatAttrs ([shouldNotRecurse] ++ recursedAttrs);
}
