[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

# Nix Dotfiles

These are my dotfiles for several nix machines.
The folder structure looks somewhat like this:

| Directory | Purpose |
|-----------|---------|
| `flake.nix` | The root of everyting. Defines the inputs and outputs of the project. See [Nix Flakes][nix-flakes] for more information. |
| `/pkgs`   | Custom packages that doesn't exist in nixpkgs. The code is also too "dirty" to add them to nixpkgs (yet). |
| `/modules` | Custom modules that I use to make my own set of "arguments" and options for the rest of the configuration. |
| `/overlays/lib` | Additions of helper functions to the standard library. |
| `/hosts` | Machine specific NixOS configurations. |
| `/hosts/common.nix` | Configuration that should be equal for all NixOS machines (or at least change based on other module options). |
| `/home` | All user specific configuration, using [home-manager][home-manager] |
| `/home/shellOptions.nix` | Settings (mostly command aliases) for all shells. |
| `/home/packages.nix` | A list of packages that should be available only to the user. This is where most of the installed packages are defined. |

## Hosts

| Host | Machine type | Purpose |
|------|--------------|---------|
| `Tsuki` | Dell Poweredge r710 server | Data storage / Build server / Selfhosted services. This server hosts a wide variety of services, including websites, matrix server, git repos, CI/CD and more. |
| `Kasei` | AMD CPU / Nvidia GFX based desktop computer | Semi-daily driver. This is my main computer at home. Most of the configuration written in `/home` is made specifically for this computer, since `Eisei` is out of service at the moment. |
| `Eisei` | HP Laptop | At the moment, this laptop is not in use. I've found that I'm not able to use NixOS quickly enough in a university environment where I need to rapidly install software and maintain project configurations (Makefile, Maven, django, npm, etc...) for several subjects. In addition to the configurations, some of the software is not available on NixOS. As a result, I would the be forced to package or FHS a lot of stuff in order to do anything productive. I might return to using NixOS on my laptop in the future. |

## Nix Secrets

Some options that are sensitive have been redacted from the files, and put into another repo. Some of the secrets are available through the `secrets` input, others are direct module configuration that is importet in `/home/home.nix`. Although this repo is required for this project to work, most of the options should be named in a way that their value type is almost guessable.

[home-manager]: https://github.com/nix-community/home-manager
[nix-flakes]: https://nixos.wiki/wiki/Flakes