{ config, pkgs, lib, ... }:
{
  services.jenkins = {
    enable = true;
    withCLI = true;
    # extraJavaOptions = [
    #   "-Dorg.jenkinsci.plugins.durabletask.BourneShellScript.LAUNCH_DIAGNOSTICS=true"
    # ];
    packages = with pkgs; [
      stdenv
      jdk17
      nix
      docker
      git
      bashInteractive # 'sh' step requires this
      coreutils
      which
      procps
    ];
  };

  users.groups.docker.members = [ "jenkins" ];
}
