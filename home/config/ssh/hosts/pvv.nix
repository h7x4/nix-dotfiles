{ pkgs, lib, extendedLib, secrets, ... }:
let
  inherit (secrets.ssh.users.pvv) normalUser adminUser;

  # http://www.pvv.ntnu.no/pvv/Maskiner
  normalMachines = [
    [ "hildring" "pvv-login" "pvv" ]
    "demiurgen"
    "eirin"
    [ "jokum" "pvv-nix" ]
    "isvegg"
    [ "microbel" "pvv-users" "pvv-mail" ]
  ];

  rootMachines = [
    [ "knakelibrak" "pvv-databases" ]
    [ "spikkjeposche" "pvv-web" "pvv-wiki" "pvv-webmail" ]
    "sleipner"
    "fenris"
    "balduzius"
    "joshua"
    "skrotnisse"
    "principal"
    "tom"
    "monty"

    {
      names = ["dvask"];
      proxyJump = "monty";
    }

    [ "innovation" "pvv-minecraft" ]
  ];

  # Either( String [String] AttrSet{String} ) -> AttrSet{String}
  normalizeValueType = let
    inherit (lib.strings) isString;
    inherit (lib.lists) isList;
    inherit (lib.attrsets) filterAttrs;
  in
    machine:
    if (isString machine) then { names = [machine]; }
    else if (isList machine) then { names = machine; }
    else machine;

  # [String] -> AttrSet
  machineWithNames = let
    inherit (lib.lists) head;
    inherit (lib.strings) split;
  in
    names: { hostname = "${head names}.pvv.org"; };

  # AttrSet -> AttrSet -> AttrSet
  convertMachineWithDefaults = defaults: normalizedMachine: let
    inherit (lib.attrsets) nameValuePair;
    inherit (lib.strings) concatStringsSep;
    inherit (normalizedMachine) names;

    name = concatStringsSep " " names;
    value =
      (machineWithNames names)
      // defaults
      // removeAttrs normalizedMachine ["names"];
  in
    nameValuePair name value;

  # AttrSet -> AttrSet
  convertNormalMachine = convertMachineWithDefaults { user = normalUser; };
  # AttrSet -> AttrSet
  convertAdminMachine =
    convertMachineWithDefaults { user = adminUser; proxyJump = "hildring"; };

  # [ Either(String [String] AttrSet{String}) ] -> (AttrSet -> AttrSet) -> AttrSet
  convertMachinesWith = convertMachineFunction: let
    inherit (lib.attrsets) listToAttrs;
    inherit (lib.trivial) pipe;
    pipeline = [
      (map normalizeValueType)
      (map convertMachineFunction)
      listToAttrs
    ];
  in
    machines: pipe machines pipeline;
in
  {
    programs.ssh.matchBlocks = extendedLib.attrsets.concatAttrs [
      (convertMachinesWith convertNormalMachine normalMachines)
      (convertMachinesWith convertAdminMachine rootMachines)
    ];
  }
