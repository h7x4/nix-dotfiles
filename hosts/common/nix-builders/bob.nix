{ config, ... }:
{
  sops.secrets."ssh/nix-builders/bob/key" = { sopsFile = ./../../../secrets/common.yaml; };

  nix.buildMachines = [{
    hostName = "nix-builder-bob";
    system = "x86_64-linux";
    speedFactor = 5;
    maxJobs = 24;
    supportedFeatures = [
      "nixos-test"
      "benchmark"
      "big-paralell"
    ];
    mandatoryFeatures = [ ];
    sshUser = "oysteikt";
    sshKey = config.sops.secrets."ssh/nix-builders/bob/key".path;
  }];

  programs.ssh = {
    extraConfig = ''
      Host nix-builder-bob
        HostName bob.pvv.ntnu.no
        ProxyJump nix-builder-isvegg
        User oysteikt
        IdentityFile ${config.sops.secrets."ssh/nix-builders/bob/key".path}
    '';

    knownHosts.bob = {
      hostNames = [
        "bob.pvv.ntnu.no"
        "bob.pvv.org"
      ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJSgh20qDIYEXiK4MUZhc879dJIyH0K/s0RZ+9wFI0F";
    };
  };
}
