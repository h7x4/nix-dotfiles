{ config, ... }:
{
  # sops.secrets."ssh/nix-builders/gluttony/key" = { sopsFile = ./../../../secrets/common.yaml; };

  nix.buildMachines = [{
    hostName = "nix-builder-gluttony";
    system = "x86_64-linux";
    speedFactor = 1;
    maxJobs = 8;
    supportedFeatures = [ ];
    mandatoryFeatures = [ ];
    sshUser = "oysteikt";
    sshKey = "/home/h7x4/.ssh/id_rsa";
    # sshKey = config.sops.secrets."ssh/nix-builders/gluttony/key".path;
  }];

  programs.ssh.extraConfig = ''
    Host nix-builder-gluttony
      HostName 129.241.100.118
      ProxyJump microbel.pvv.ntnu.no
      User oysteikt
      IdentityFile "/home/h7x4/.ssh/id_rsa"
  '';
}
