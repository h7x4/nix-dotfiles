{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-local = {
      url = "git+file:///home/h7x4/git/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    dotfiles = {
      url = "git+https://git.nani.wtf/h7x4/dotfiles?ref=master";
      flake = false;
    };

    nix-attr-search ={
      url = "github:h7x4/nix-attr-search";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    fonts = {
      url = "path:/home/h7x4/git/fonts";
      flake = false;
    };

    osuchan = {
      url = "git+file:///home/h7x4/git/osuchan-line-bot";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    website = {
      url = "git+https://git.nani.wtf/h7x4/nani.wtf?ref=main";
      # url = "path:/home/h7x4/git/nani.wtf";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    maunium-stickerpicker = {
      url = "git+file:///home/h7x4/git/maunium-stickerpicker-nix";
    };

    minecraft = {
      url = "github:infinidoge/nix-minecraft";
    };

    matrix-synapse-next = {
      url = "github:dali99/nixos-matrix-modules";
    };

    vscode-server = {
      url = "github:msteen/nixos-vscode-server";
      flake = false;
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
    nix-attr-search,
    osuchan,
    secrets,
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

      overlays = [ osuchan.overlays.default ];
    };

    pkgs = import nixpkgs pkgs-config;
    unstable-pkgs = import nixpkgs-unstable pkgs-config;
  in {
    extendedLib = import ./lib { stdlib = pkgs.lib; };

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
            ./modules
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
            ./modules
            ./hosts/common.nix
            ./hosts/${name}/configuration.nix
            "${vscode-server}/default.nix"

            secrets.outputs.nixos-config
            osuchan.outputs.nixosModules.default
            minecraft.outputs.nixosModules.minecraft-servers
            matrix-synapse-next.nixosModules.synapse

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
                  secrets = secrets.outputs.settings;
                };

                users.h7x4 = import ./home/home.nix {
                  inherit pkgs;
                  inherit inputs;
                  inherit (pkgs) lib;
                  inherit (config) machineVars colors;
                  inherit (self) extendedLib;
                };
              };
            })
          ];
        };
    in {
      Tsuki = nixSys "tsuki";
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
