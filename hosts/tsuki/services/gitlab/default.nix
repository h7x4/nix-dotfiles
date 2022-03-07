{ pkgs, lib, config, secrets, ... }:
let
  gitlab-port = secrets.ports.gitlab;
  gitlab-host = "gitlab.nani.wtf";

  # TODO: this should optimally be extracted out to nix-secrets completely.
  gitlab-keydir = secrets.hosts.${config.networking.hostName}.keydir + "/gitlab";
in
{
  # TODO: Set up gitlab-runner
  # imports = [ ./runner.nix ];

  services.gitlab = {
    enable = false;

    host = gitlab-host;
    port = gitlab-port + 1;

    user = "gitlab";
    group = "gitlab";

    databaseUsername = "gitlab";

    statePath = "${secrets.hosts.${config.networking.hostName}.dataStatePath}/gitlab";

    # A file containing the initial password of the root gitlab-account.
    # This file should be readable to the user defined in `services.gitlab.user`,
    # optimally having only read write permissions for that user.
    initialRootPasswordFile = secrets.keys.gitlab.root_password;

    secrets = { inherit (secrets.keys.gitlab) secretFile dbFile otpFile jwsFile; };


    # TODO: Activate GitLabs Prometheus service
    # extraGitlabRb = ''
    #   prometheus['enabled'] = true
    #   prometheus['server_address'] = '0.0.0.0:10392'
    # '';

    smtp = {
      tls = true;
      # address = gitlab-host;
      port = gitlab-port + 2;
    };

    # TODO: Set up registry
    # registry = {
    #   enable = true;
    #   # host = gitlab-host;
    #   port = gitlab-port + 3;
    #   externalPort = gitlab-port + 3;
    #   certFile = /var/cert.pem;
    #   keyFile = /var/key.pem;
    # };

    pagesExtraArgs = [
       "-gitlab-server" "http://${gitlab-host}" 
       "-listen-proxy" "127.0.0.1:${toString (gitlab-port + 4)}" 
       "-log-format" "text" 
    ];

    # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/gitlab.nix
    # https://gitlab.com/gitlab-org/gitlab/blob/master/config/gitlab.yml.example
    extraConfig = {
      # gitlab = {};
      gravatar.enabled = false;

      # TODO: Fix pages API connection
      # pages = {
      #   enabled = true;
      #   host = gitlab-host;
      #   secret_file = "${toString gitlab-keydir}/pages_secret";
      #   local_store.enabled = true;
      # };
    };

  };

  # TODO: Set up registry
  # services.dockerRegistry = {
  #   enable = true;
  # };

  # TODO: Connect plantuml to gitlab
  services.plantuml-server = {
    enable = true;
    listenPort = gitlab-port + 5;
  };

  # TODO: Make module for kroki, and connect to gitlab
  # services.kroki = {
  #   
  # };
}
