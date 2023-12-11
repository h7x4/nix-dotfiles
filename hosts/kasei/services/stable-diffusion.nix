
{ pkgs, ... }:
{
  systemd.services.sdwebui = {
    description = "Stable Diffusion Web UI";
    wants = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    path = with pkgs; [
      nix
      git
      nix-output-monitor
      bash
    ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "/home/h7x4/sd-webui/run.sh";
      User = "h7x4";
      ExecReload = "/bin/kill -HUP $MAINPID";
      Restart="on-failure";
      WorkingDirectory = "/home/h7x4/sd-webui";
    };
  };

  networking.firewall.allowedTCPPorts = [ 7860 ];
}
