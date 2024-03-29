[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

# Nix Dotfiles

These are my dotfiles for several nix machines.
Here are some of the interesting files and dirs:

| Path | Purpose |
|------|---------|
| `/home` | [home-manager][home-manager] configuration. |
| `/hosts` | Machine specific NixOS configurations. |
| `/hosts/common.nix` | Configuration that is equal for all hosts. |
| `/lib` | Custom lib functions that has not been upstreamed (or should not be) to nixpkgs. I'm trying to phase these out as much as possible. |
| `/modules` | Custom nixos modules that I use in my own configuration. If you see options that does not appear in [NixOS Search][nixos-search], they might be defined here. |
| `/package-overrides` | Updated or pinned versions of packages that have not been upstreamed to nixpkgs (yet). |
| `/secrets` | Encrypted [sops-nix][sops-nix] secrets. |
| `flake.nix` | The root of everyting. Defines the inputs and outputs of the project. Also applies misc overlays and adds config-wide modules. See [Nix Flakes][nix-flakes] for more information. |

## Hosts

| Host | Machine type | Purpose |
|------|--------------|---------|
| `Tsuki` | Dell Poweredge r710 server | Data storage / Build server / Selfhosted services. This server hosts a wide variety of services, including websites, matrix server, git repos, CI/CD and more. **This is probably the most interesting machine to pick config from** |
| `Kasei` | AMD Zen 2 CPU / Nvidia GPU - desktop computer | Semi-daily driver. This is my main computer at home. Most of the configuration written in `/home` is made specifically for this computer, since `Eisei` is out of service at the moment. |
| `Eisei` | HP Laptop | At the moment, this laptop is not in use. I've found that I'm not able to use NixOS quickly enough in a university environment where I need to rapidly install software and maintain project configurations (Makefile, Maven, django, npm, etc...) for several subjects. In addition to the configurations, some of the software is not available on NixOS. As a result, I would the be forced to package or FHS a lot of stuff in order to do anything productive. I might return to using NixOS on my laptop in the future. |

## home-manager configuration

| Path | Purpose |
|------|---------|
| `/home/config` | Configuration for everything that is not a program, nor a service, and are big enough to warrant their own file or directory. |
| `/home/modules` | Custom home-manager modules. |
| `/home/packages.nix` | A list of packages that should be included in the environment. |
| `/home/programs` | Configuration for programs that have their own home-manager modules. |
| `/home/services` | Configuration for services/daemons that are user-specific. |
| `/home/shell.nix` | Shell-agnostic configuration. This includes aliases, envvars, functions, etc. |

[home-manager]: https://github.com/nix-community/home-manager
[nixos-search]: https://search.nixos.org/options
[sops-nix]: https://github.com/Mic92/sops-nix
[nix-flakes]: https://nixos.wiki/wiki/Flakes
