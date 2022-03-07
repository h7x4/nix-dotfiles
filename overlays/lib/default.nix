final: prev: 
{
  lib = prev.lib // {
    attrsets =   (import ./attrsets.nix) final prev;
    lists =      (import ./lists.nix) final prev;
    strings =    (import ./strings.nix) final prev;
    termColors = (import ./termColors.nix) final prev;
    trivial =    (import ./trivial.nix) final prev;
  };
}
