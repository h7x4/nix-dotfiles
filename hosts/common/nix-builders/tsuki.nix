{ config, secrets, ... }:
{
  # TODO: install public key on tsuki declaratively
  sops.secrets = {
    "ssh/nix-builders/tsuki/key" = { sopsFile = ./../../../secrets/common.yaml; };
    "ssh/nix-builders/tsuki/pub" = { sopsFile = ./../../../secrets/common.yaml; };
  };

  nix.buildMachines = [{
    # Login details configured in ssh module in nix-secrets
    hostName = "nix-builder-tsukir";
    system = "x86_64-linux";
    speedFactor = 2;
    maxJobs = 8;
    supportedFeatures = [
      "nixos-test"
      "benchmark"
      "big-paralell"
    ];
    mandatoryFeatures = [ ];
    sshUser = "nix-ssh";
    sshKey = config.sops.secrets."ssh/nix-builders/tsuki/key".path;
  }];

  programs.ssh.extraConfig = ''
    Host nix-builder-tsukir
      HostName gingakei.loginto.me
      Port ${toString secrets.ports.ssh.home-in}
  '';
}