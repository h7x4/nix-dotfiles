{ config, secrets, ... }:
{
  sops.secrets."ssh/nix-builders/isvegg/key" = { sopsFile = ./../../../secrets/common.yaml; };

  nix.buildMachines = [{
    # Login details configured in ssh module in nix-secrets
    hostName = "nix-builder-isvegg";
    system = "x86_64-linux";
    speedFactor = 1;
    maxJobs = 8;
    supportedFeatures = [ ];
    mandatoryFeatures = [ ];
    sshUser = secrets.ssh.users.pvv.normalUser;
    sshKey = config.sops.secrets."ssh/nix-builders/isvegg/key".path;
  }];

  programs.ssh.extraConfig = ''
    Host nix-builder-isvegg
      HostName isvegg.pvv.ntnu.no
      User oysteikt
      IdentityFile ${config.sops.secrets."ssh/nix-builders/isvegg/key".path}
  '';
}