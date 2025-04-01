{ pkgs, lib, ... }:
let # http://www.pvv.ntnu.no/pvv/Maskiner
  normalMachines = [
    {
      names = [ "hildring" "pvv-login" ];
      proxyJump = lib.mkDefault null;
      addressFamily = "inet";
    }
    {
      names = [ "drolsum" "pvv-login2" "pvv" ];
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
    "eirin"
    "georg"
    "ildkule"
    "isvegg"
    "knutsen"
    "kommode"
    {
      names = [ "microbel" "pvv-users" "pvv-mail" ];
      proxyJump = lib.mkDefault null;
      addressFamily = "inet";
    }
    "orchid"
    "shark"
    "tallulah"
    "tom"
    "ustetind"
    "venture"
  ];

  rootMachines = [
    [ "ameno" "pvv-dns" ]
    [ "balduzius" "pvv-krb" ]
    [ "innovation" "pvv-minecraft" ]
    "ludvigsen"
    [ "principal" "pvv-backup" ]
    [ "skrott" "dibbler" ]
    {
      names = [ "sleipner" "pvv-salt" ];
      user = "oysteikt/admin";
    }
  ];

  overrideIfNotExists = b: a: a // (builtins.removeAttrs b (builtins.attrNames a));

  coerce = user: machines: lib.pipe machines [
    (m: if builtins.isString m then { names = [m]; } else m)
    (m: if builtins.isList m then { names = m; } else m)
    (overrideIfNotExists { inherit user; })
  ];

  normalUser = "oysteikt";

  matchConfig = let
    machines = (map (coerce normalUser) normalMachines) ++ (map (coerce "root") rootMachines);
    setVars = orig@{ names, ... }: {
      name = builtins.concatStringsSep " " names;
      value = overrideIfNotExists {
        hostname = "${builtins.head names}.pvv.ntnu.no";
        proxyJump = "microbel";
        addressFamily = "inet";
      } (builtins.removeAttrs orig ["names"]);
    };
  in builtins.listToAttrs (map setVars machines);

in
  {
    programs.ssh.matchBlocks = lib.mergeAttrsList [
      matchConfig
      {
        "pvv-git git.pvv.ntnu.no" = {
          hostname = "git.pvv.ntnu.no";
          user = "gitea";
          addressFamily = "inet";
          port = 2222;
          proxyJump = "microbel";
        };
      }
    ];
  }
