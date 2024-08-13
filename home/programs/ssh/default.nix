{ config, ... }:
{
  imports = [
    ./home.nix
    ./other.nix
    ./pvv.nix
  ];

  sops.secrets."ssh/secret-config" = {
    mode = "0444";
  };

  programs.ssh.includes = [ config.sops.secrets."ssh/secret-config".path ];
}
