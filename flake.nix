{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-local = {
      url = "git+file:///home/h7x4/git/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    dotfiles = {
      url = "git+https://git.pvv.ntnu.no/oysteikt/dotfiles?ref=master";
      flake = false;
    };

    fonts = {
      url = "path:/home/h7x4/git/fonts";
      flake = false;
    };

    sops-nix.url = "github:Mic92/sops-nix";

    osuchan = {
      url = "git+file:///home/h7x4/git/osuchan-line-bot";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    website = {
      url = "git+https://git.pvv.ntnu.no/oysteikt/nani.wtf?ref=main";
      # url = "path:/home/h7x4/git/nani.wtf";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    maunium-stickerpicker = {
      # url = "git+file:///home/h7x4/git/maunium-stickerpicker-nix";
      url = "github:h7x4/maunium-stickerpicker-nix/project-rewrite";
    };

    minecraft = {
      url = "github:infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    matrix-synapse-next = {
      url = "github:dali99/nixos-matrix-modules/v0.6.0";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
    };

    # Nix expressions and keys (TODO: move keys to another solution like agenix)
    # which should be kept from the main repo for privacy reasons.
    #
    # Includes stuff like usernames, emails, ports, other server users, ssh hosts, etc.
    secrets = {
      # TODO: Push this to a remote.
      url = "git+file:///home/h7x4/git/nix-secrets";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    home-manager-local,

    dotfiles,
    fonts,
    matrix-synapse-next,
    maunium-stickerpicker,
    minecraft,
    osuchan,
    secrets,
    sops-nix,
    vscode-server,
    website
  }: let
    system = "x86_64-linux";

    pkgs-config = {
      inherit system;

      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };

      overlays = let
        nonrecursive-unstable-pkgs = nixpkgs-unstable.legacyPackages.${system};
      in [
        (self: super: { pgadmin4 = nonrecursive-unstable-pkgs.pgadmin4; })
        # (self: super: { pcloud = nonrecursive-unstable-pkgs.pcloud; })
        osuchan.overlays.default
        (self: super: {
          mpv-unwrapped = super.mpv-unwrapped.override {
            ffmpeg = super.ffmpeg_6-full;
          };
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
      nixSys = name:
        nixpkgs.lib.nixosSystem {
          inherit system;
          inherit pkgs;
          inherit (pkgs) lib;
          modules = [
            "${home-manager}/nixos"
            ./modules/machineVars.nix
            ./modules/socketActivation.nix
            ./hosts/common.nix
            ./hosts/${name}/configuration.nix

            matrix-synapse-next.nixosModules.default
            osuchan.outputs.nixosModules.default
            secrets.outputs.nixos-config
            sops-nix.nixosModules.sops
            vscode-server.nixosModules.default
            maunium-stickerpicker.nixosModules.default

            (args: import minecraft.outputs.nixosModules.minecraft-servers (args // {
              pkgs = unstable-pkgs;
              lib = unstable-pkgs.lib;
            }))

            {
              config._module.args = {
                inherit inputs;
                inherit unstable-pkgs;
                inherit (self) extendedLib;
                secrets = secrets.outputs.settings;
              };
            }

            ({ config, ... }:
            {
              home-manager = {
                useGlobalPkgs = true;
                extraSpecialArgs = {
                  inherit inputs;
                  inherit (self) extendedLib;
                  inherit (config) machineVars;
                  secrets = secrets.outputs.settings;
                };

                users.h7x4 = {
                  imports = [ ./home/home.nix ];
                };
              };
            })
          ];
        };
    in {
      tsuki = nixSys "tsuki";
      Eisei = nixSys "eisei";
      kasei = nixSys "kasei";
      home-manager-tester = nixpkgs-unstable.lib.nixosSystem {
        inherit system;
        pkgs = unstable-pkgs;
        inherit (unstable-pkgs) lib;
        modules = [
          "${home-manager-local}/nixos"
          ./hosts/special/home-manager-tester/configuration.nix
          {
            config._module.args = {
              pkgs = unstable-pkgs;
              # inherit (self) extendedLib;
              # secrets = secrets.outputs.settings;
            };
          }
        ];
      };
    };
  };
}
