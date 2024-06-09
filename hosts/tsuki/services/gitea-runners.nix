{ config, pkgs, lib, ... }:
{
  virtualisation.podman.enable = true;
  virtualisation.podman.autoPrune.enable = true;
  networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 5353 ];

  sops.secrets."gitea/runners/ping".restartUnits = [ "gitea-runner-ping.service" ];
  sops.secrets."gitea/runners/pong".restartUnits = [ "gitea-runner-pong.service" ];

  services.gitea-actions-runner.instances = let
    mkRunner = name: {
      ${name} = {
        enable = true;
        name = "git-runner-${name}";
        url = "https://git.pvv.ntnu.no";
        labels = [
	        "debian-latest:docker://node:latest"
	        "ubuntu-latest:docker://node:latest"
	        "debian-latest-personal:docker://node:latest"
	        "ubuntu-latest-personal:docker://node:latest"
	      ];
        tokenFile = config.sops.secrets."gitea/runners/${name}".path;
      };
    };
  in lib.foldl (a: b: a // b) { } [
    (mkRunner "ping")
    (mkRunner "pong")
  ];
}
