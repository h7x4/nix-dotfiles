{
  description = "Mmmmmh, Spaghetti™";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-21.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    dotfiles = {
      url = "github:h7x4abk3g/dotfiles";
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

  outputs = { self, nixpkgs, home-manager, secrets, dotfiles, ... }: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;

      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };

      overlays = [ (import ./overlays/lib) ];
    };

    specialArgs = {
      secrets = secrets.outputs.default;
      colorTheme = import ./common/colors.nix;
      inputs = {
        home-manager = home-manager;
        secrets = secrets;
        dotfiles = dotfiles;
      };
    };

  in {
    overlays = {
      lib = import ./overlays/lib;
    };

    homeConfigurations = {
      h7x4 = home-manager.lib.homeManagerConfiguration {
        inherit system;
        inherit pkgs;

        extraSpecialArgs = specialArgs;
        username = "h7x4";
        homeDirectory = "/home/h7x4";
        stateVersion = "21.11";
        configuration = {

          imports = [
            ./home.nix
            secrets.outputs.nixosModule
          ];
        };
      };
    };

    nixosConfigurations = let
      # String -> AttrSet -> AttrSet
      nixSys =
        name: extraOpts:
        nixpkgs.lib.nixosSystem {
          inherit system;
          inherit pkgs;

          lib = pkgs.lib;
          inherit specialArgs;

          modules = [
            ./hosts/${name}/configuration.nix
          ];
        } // extraOpts;

    in {
      Tsuki = nixSys "tsuki" {};
      Eisei = nixSys "eisei" {};
      kasei = nixSys "kasei" {};
    };

  };
}
