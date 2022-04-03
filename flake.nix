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

    fonts = {
      url = "path:/home/h7x4/git/fonts";
      flake = false;
    };

    website = {
      url = "git+https://git.nani.wtf/h7x4/nani.wtf?ref=main";
      # url = "path:/home/h7x4/git/nani.wtf";
      inputs.nixpkgs.follows = "nixpkgs";
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

  outputs = {
    self,
    nixpkgs,
    home-manager,
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

    specialArgs = {
      secrets = secrets.outputs.default;
      colorTheme = import ./common/colors.nix;
      inputs = {
        inherit self;
        inherit home-manager;
        inherit dotfiles;
        inherit fonts;
        inherit website;
        inherit secrets;
      };
    };

  in {
    overlays = {
      lib = import ./overlays/lib;
    };

    lib = (pkgs.extend self.overlays.lib).lib;

    homeConfigurations = {
      h7x4 = home-manager.lib.homeManagerConfiguration {
        inherit system;
        inherit pkgs;

        extraSpecialArgs = specialArgs // {
          machineVars = {
            hostname = "machine";
            headless = false;
            screens = 1;
            gaming = true;
            laptop = false;
          };
        };
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
      nixSys = name: extraOpts: machineVars:
        nixpkgs.lib.nixosSystem {
          inherit system;
          inherit pkgs;
          inherit (pkgs) lib;
          specialArgs = specialArgs // { inherit machineVars; };
          modules = [
            "${home-manager}/nixos"
            ./hosts/common.nix
            ./hosts/${name}/configuration.nix
          ];
        } // extraOpts;

    in {
      Tsuki = nixSys "tsuki" {} {
        hostname = "tsuki";
        headless = true;
        gaming = false;
        laptop = false;
      };
      Eisei = nixSys "eisei" {} {
        hostname = "eisei";
        headless = false;
        screens = 1;
        gaming = false;
        laptop = true;
      };
      kasei = nixSys "kasei" {} {
        hostname = "kasei";
        headless = false;
        screens = 2;
        gaming = true;
        laptop = false;
      };
    };

  };
}
