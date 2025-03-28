{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
    nixpkgs-yet-unstabler.url = "github:NixOS/nixpkgs/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    osuchan = {
      url = "git+file:///home/h7x4/git/osuchan-line-bot";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    maunium-stickerpicker = {
      url = "github:h7x4/maunium-stickerpicker-nix/0.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    minecraft = {
      url = "github:infinidoge/nix-minecraft/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    matrix-synapse-next = {
      url = "github:dali99/nixos-matrix-modules/0.7.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    anyrun = {
      url = "git+https://git.pvv.ntnu.no/oysteikt/anyrun?ref=plugins-application-preprocess-exec";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-yet-unstabler,
    home-manager,
    nixos-hardware,

    matrix-synapse-next,
    maunium-stickerpicker,
    minecraft,
    osuchan,
    sops-nix,
    anyrun,
  }: let
    system = "x86_64-linux";

    pkgs-config = {
      inherit system;

      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
        segger-jlink.acceptLicense = true;
        permittedInsecurePackages = [
          "segger-jlink-qt4-796s"
          "dotnet-core-combined"
          "dotnet-sdk-6.0.428"
          "dotnet-sdk-wrapped-6.0.428"
        ];
      };

      overlays = let
        nonrecursive-unstable-pkgs = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
          config.segger-jlink.acceptLicense = true;
          config.permittedInsecurePackages = [
            "segger-jlink-qt4-796s"
          ];
        };
      in [
        (import ./overlays/wayland-ime-integration.nix)

        (import ./overlays/pcloud.nix {
          inherit (nixpkgs) lib;
          pkgs = nonrecursive-unstable-pkgs;
        })

        (_: _: {
          linuxPackages_latest = nonrecursive-unstable-pkgs.linuxPackages_latest;
        })

        minecraft.overlays.default
        osuchan.overlays.default
      ];
    };

    pkgs = import nixpkgs pkgs-config;
    unstable-pkgs = import nixpkgs-unstable pkgs-config;
    yet-unstabler-pkgs = import nixpkgs-yet-unstabler pkgs-config;
  in {
    inherit pkgs;
    inherit (nixpkgs) lib;

    extendedLib = import ./lib { stdlib = pkgs.lib; };

    inputs = pkgs.lib.mapAttrs (_: src: src.outPath) inputs;

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [ sops ];
    };

    nixosModules = {
      machineVars = ./modules/machineVars.nix;
      socketActivation = ./modules/socketActivation.nix;
    };

    homeModules = {
      uidGid = ./home/modules/uidGid.nix;
      shellAliases = ./home/modules/shellAliases.nix;
      colors = ./home/modules/colors.nix;
      gpg = ./home/modules/programs/gpg;
      neovim-auto-clean-swapfiles = ./home/modules/programs/neovim/auto-clean-swapfiles.nix;
      nix-index-auto-update-database = ./home/modules/programs/nix-index/auto-update-database.nix;
      direnv-auto-prune = ./home/modules/programs/direnv/auto-prune.nix;
      newsboat = ./home/modules/programs/newsboat;
    };

    homeConfigurations = {
      h7x4 = home-manager.lib.homeManagerConfiguration {
        inherit system;
        inherit pkgs;

        username = "h7x4";
        homeDirectory = "/home/h7x4";
        stateVersion = "25.05";
        configuration = {
          imports = [
            ./home/home.nix
            ./modules/machineVars.nix
          ];

          machineVars = {
            headless = false;
            fixDisplayCommand = "echo 'not available'";
            gaming = true;
            development = true;
            laptop = false;
          };
        };
      };
    };

    nixosConfigurations = let
      nixSys = name: extraConfig:
        nixpkgs.lib.nixosSystem
          ({
            inherit system;
            inherit pkgs;
            inherit (pkgs) lib;

            specialArgs = {
              inherit inputs;
              inherit unstable-pkgs;
              inherit yet-unstabler-pkgs;
              inherit (self) extendedLib;
            } // (extraConfig.specialArgs or { });

            modules = [
              "${home-manager}/nixos"

              ./hosts/common
              ./hosts/${name}/configuration.nix

              ./modules/machineVars.nix
              ./modules/socketActivation.nix

              sops-nix.nixosModules.sops

              ({ config, ... }:
              {
                home-manager = {
                  useGlobalPkgs = true;
                  extraSpecialArgs = {
                    inherit inputs;
                    inherit unstable-pkgs;
                    inherit yet-unstabler-pkgs;
                    inherit (self) extendedLib;
                    inherit (config) machineVars;
                  };

                  sharedModules = [
                    inputs.sops-nix.homeManagerModules.sops
                    inputs.anyrun.homeManagerModules.default
                  ];

                  users.h7x4.imports = [
                    ./home/home.nix
                    ./hosts/${name}/home
                  ];
                };
              })
            ] ++ (extraConfig.modules or [ ]);
          }
          //
          (builtins.removeAttrs extraConfig [
            "modules"
            "specialArgs"
          ]));
    in {
      dosei = nixSys "dosei" {
        modules = [
          {
            home-manager.users.h7x4.home.uid = 1001;
          }

          nixos-hardware.nixosModules.common-pc
          nixos-hardware.nixosModules.common-pc-ssd
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-gpu-intel
        ];
      };
      kasei = nixSys "kasei" {
        modules = [
          nixos-hardware.nixosModules.common-pc
          nixos-hardware.nixosModules.common-pc-ssd
          nixos-hardware.nixosModules.common-cpu-amd
          nixos-hardware.nixosModules.common-cpu-amd-pstate
          nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
        ];
      };
      xps16 = nixSys "xps16" {
        modules = [
          nixos-hardware.nixosModules.common-hidpi
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-gpu-intel
        ];
      };
      europa = nixSys "europa" {
        modules = [
          nixos-hardware.nixosModules.common-pc
          nixos-hardware.nixosModules.common-pc-ssd
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-gpu-intel
        ];
      };
      tsuki = nixSys "tsuki" {
        modules = [
          matrix-synapse-next.nixosModules.default
          osuchan.outputs.nixosModules.default
          maunium-stickerpicker.nixosModules.default

          (args: import minecraft.outputs.nixosModules.minecraft-servers (args // {
            pkgs = unstable-pkgs;
            lib = unstable-pkgs.lib;
          }))
        ];
      };
    };
  };
}
