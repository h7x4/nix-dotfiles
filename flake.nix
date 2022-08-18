{
  description = "Mmmmmh, Spaghetti™";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    unstable-nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
      # url = "git+file:///home/h7x4/git/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfiles = {
      url = "github:h7x4abk3g/dotfiles";
      flake = false;
    };

    fonts = {
      url = "path:/home/h7x4/git/fonts";
      flake = false;
    };

    website = {
      url = "git+https://git.nani.wtf/h7x4/nani.wtf?ref=main";
      # url = "path:/home/h7x4/git/nani.wtf";
      inputs.nixpkgs.follows = "nixpkgs";
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
    unstable-nixpkgs,
    home-manager,
    vscode-server,
    secrets,
    fonts,
    dotfiles,
    website,
    ...
  }: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;

      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };

      overlays = [ self.overlays.lib ];
    };

    unstable-pkgs = import unstable-nixpkgs {
      inherit system;

      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };

      overlays = [ self.overlays.lib ];
    };

  in {
    overlays = {
      lib = import ./overlays/lib;
    };

    lib = (pkgs.extend self.overlays.lib).lib;

    packages.${system} = import ./pkgs { inherit pkgs; };

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
            {
              config._module.args = {
                inherit inputs;
                inherit unstable-pkgs;
                secrets = secrets.outputs.default;
              };
            }
          ];
        };
    in {
      Tsuki = nixSys "tsuki";
      Eisei = nixSys "eisei";
      kasei = nixSys "kasei";
    };
  };
}
