{ config, ... }:
{
  sops.secrets."ssh/nix-builders/bob/key" = { sopsFile = ./../../../secrets/common.yaml; };

  nix.buildMachines = [{
    # Login details configured in ssh module in nix-secrets
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
    # sshUser = secrets.ssh.users.pvv.normalUser;
    # sshKey = config.sops.secrets."ssh/nix-builders/bob/key".path;
  }];

  programs.ssh.extraConfig = ''
    Host nix-builder-bob
      HostName bob.pvv.ntnu.no
      ProxyJump nix-builder-isvegg
      User oysteikt
      IdentityFile ${config.sops.secrets."ssh/nix-builders/bob/key".path}
  '';
}