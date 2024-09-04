{ pkgs, lib, extendedLib, ... }:
let
  adminUser = "root";
  normalUser = "oysteikt";

  # http://www.pvv.ntnu.no/pvv/Maskiner
  normalMachines = [
    {
      names = [ "hildring" "pvv-login" "pvv" ];
      proxyJump = lib.mkDefault null;
      addressFamily = "inet";
    }
    [ "bekkalokk" "pvv-web" "pvv-wiki" "pvv-webmail" ]
    [ "bicep" "pvv-databases" ]
    "bob"
    [ "brzeczyszczykiewicz" "brez" "bokhylle" ]
    "buskerud"
    "dagali"
    "demiurgen"
    "drolsum"
    "eirin"
    "georg"
    "ildkule"
    "isvegg"
    "knutsen"
    [ "microbel" "pvv-users" "pvv-mail" ]
    "orchid"
    "shark"
    "tallulah"
    "tom"
    "venture"
  ];

  rootMachines = [
    [ "ameno" "pvv-dns" ]
    [ "balduzius" "pvv-krb" ]
    [ "innovation" "pvv-minecraft" ]
    "ludvigsen"
    [ "principal" "pvv-backup" ]
    [ "skrott" "dibbler" ]
    [ "sleipner" "pvv-salt" ]
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
  convertNormalMachine = convertMachineWithDefaults { user = normalUser; proxyJump = "pvv"; };
  # AttrSet -> AttrSet
  convertAdminMachine =
    convertMachineWithDefaults { user = adminUser; proxyJump = "pvv"; };

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
    programs.ssh.matchBlocks = (extendedLib.attrsets.concatAttrs [
      (convertMachinesWith convertNormalMachine normalMachines)
      (convertMachinesWith convertAdminMachine rootMachines)
    ]) // {
      "pvv-git git.pvv.ntnu.no" = {
        hostname = "git.pvv.ntnu.no";
        user = "gitea";
        addressFamily = "inet";
        port = 2222;
        proxyJump = "pvv";
      };
    };
  }
