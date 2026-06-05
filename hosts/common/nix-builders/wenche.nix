{ config, ... }:
{
  # sops.secrets."ssh/nix-builders/wenche/key" = { sopsFile = ./../../../secrets/common.yaml; };

  nix.buildMachines = [{
    hostName = "nix-builder-wenche";
    system = "x86_64-linux";
    speedFactor = 1;
    maxJobs = 8;
    supportedFeatures = [ ];
    mandatoryFeatures = [ ];
    sshUser = "oysteikt";
    sshKey = "/home/h7x4/.ssh/id_rsa";
    # sshKey = config.sops.secrets."ssh/nix-builders/wenche/key".path;
  }];

  programs.ssh.extraConfig = ''
    Host nix-builder-wenche
      HostName wenche.pvv.ntnu.no
      ProxyJump microbel.pvv.ntnu.no
      User oysteikt
      IdentityFile "/home/h7x4/.ssh/id_rsa"
  '';
}
