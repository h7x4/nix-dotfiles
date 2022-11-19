{ stdlib }: 
rec {
  attrsets =   import ./attrsets.nix { inherit stdlib; };
  lists =      import ./lists.nix { inherit stdlib; };
  strings =    import ./strings.nix { inherit stdlib lists; };
  termColors = import ./termColors.nix { inherit stdlib strings; };
  trivial =    import ./trivial.nix { inherit stdlib; };
}
