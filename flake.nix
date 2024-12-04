{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    # nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfiles = {
      url = "git+https://git.pvv.ntnu.no/oysteikt/dotfiles?ref=master";
      flake = false;
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    osuchan = {
      url = "git+file:///home/h7x4/git/osuchan-line-bot";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: fix website
    # website = {
    #   url = "git+https://git.pvv.ntnu.no/oysteikt/nani.wtf?ref=main";
      # url = "path:/home/h7x4/git/nani.wtf";
      # inputs.nixpkgs.follows = "nixpkgs";
    # };

    maunium-stickerpicker = {
      url = "github:h7x4/maunium-stickerpicker-nix/0.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    minecraft = {
      url = "github:infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    matrix-synapse-next = {
      url = "github:dali99/nixos-matrix-modules/v0.6.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,

    dotfiles,
    matrix-synapse-next,
    maunium-stickerpicker,
    minecraft,
    osuchan,
    sops-nix,
    vscode-server,
    # website
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
        (self: super: {
          inherit (nonrecursive-unstable-pkgs)
              fcitx5-mozc
            ;
        })
      ];
    };

    pkgs = import nixpkgs pkgs-config;
    unstable-pkgs = import nixpkgs-unstable pkgs-config;
  in {
    extendedLib = import ./lib { stdlib = pkgs.lib; };

    inherit pkgs;

    packages.${system} = {
      inherit (pkgs) kanidm pcloud;
    };

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [ sops ];
    };

    homeConfigurations = {
      h7x4 = home-manager.lib.homeManagerConfiguration {
        inherit system;
        inherit pkgs;

        username = "h7x4";
        homeDirectory = "/home/h7x4";
        stateVersion = "22.05";
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
                    inherit (self) extendedLib;
                    inherit (config) machineVars;
                  };

                  sharedModules = [
                    inputs.sops-nix.homeManagerModules.sops
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
        modules = [{
          home-manager.users.h7x4.home.uid = 1001;
        }];
      };
      kasei = nixSys "kasei" { };
      xps16 = nixSys "xps16" { };
      europa = nixSys "europa" { };
      tsuki = nixSys "tsuki" {
        modules = [
          matrix-synapse-next.nixosModules.default
          osuchan.outputs.nixosModules.default
          vscode-server.nixosModules.default
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
