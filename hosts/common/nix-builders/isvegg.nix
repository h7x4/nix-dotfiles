{ config, ... }:
{
  sops.secrets."ssh/nix-builders/isvegg/key" = { sopsFile = ./../../../secrets/common.yaml; };

  nix.buildMachines = [{
    hostName = "nix-builder-isvegg";
    system = "x86_64-linux";
    speedFactor = 1;
    maxJobs = 8;
    supportedFeatures = [ ];
    mandatoryFeatures = [ ];
    sshUser = "oysteikt";
    sshKey = config.sops.secrets."ssh/nix-builders/isvegg/key".path;
  }];

  programs.ssh.extraConfig = ''
    Host nix-builder-isvegg
      HostName isvegg.pvv.ntnu.no
      User oysteikt
      IdentityFile ${config.sops.secrets."ssh/nix-builders/isvegg/key".path}
  '';
}
