{ pkgs, lib, extendedLib, ... }:
let
  adminUser = "root";
  normalUser = "oysteikt";

  # http://www.pvv.ntnu.no/pvv/Maskiner
  normalMachines = [
    [ "hildring" "pvv-login" "pvv" ]
    "demiurgen"
    "eirin"
    "bekkalokk"
    "ildkule"
    "shark"
    "buskerud"
    "bicep"
    {
      names = [ "bob" ];
      proxyJump = "hildring";
    }
    "knutsen"
    "isvegg"
    [ "microbel" "pvv-users" "pvv-mail" ]
  ];

  rootMachines = [
    [ "knakelibrak" "pvv-databases" ]
    [ "spikkjeposche" "pvv-web" "pvv-wiki" "pvv-webmail" ]
    "sleipner"
    # "fenris"
    "balduzius"
    "joshua"
    # "skrotnisse"
    "principal"
    "tom"
    # "monty"
    # {
    #   names = [ "dvask" ];
    #   proxyJump = "monty";
    # }

    [ "innovation" "pvv-minecraft" ]
  ];

  # Either( String [String] AttrSet{String} ) -> AttrSet{String}
  coerceToSSHMatchBlock =
    machine:
    if builtins.isString machine then { names = [machine]; }
    else if builtins.isList machine then { names = machine; }
    else machine;

  # ListOf(String) -> AttrSet
  machineWithNames = let
    inherit (lib.lists) head;
    inherit (lib.strings) split;
  in
    names: { hostname = "${head names}.pvv.ntnu.no"; };

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

  # ListOf (Either(String ListOf(String) AttrsOf(String))) -> (AttrSet -> AttrSet) -> AttrSet
  convertMachinesWith = convertMachineFunction: let
    inherit (lib.attrsets) listToAttrs;
    inherit (lib.trivial) pipe;
    pipeline = [
      (map coerceToSSHMatchBlock)
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
