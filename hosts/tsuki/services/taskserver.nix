{ pkgs, config, ... }:
{
  security.acme.certs."tasks.nani.wtf" = {
    group = config.services.taskserver.group;
  };

  systemd.services.taskserver.serviceConfig = {
    ReadOnlyPaths = config.security.acme.certs."tasks.nani.wtf".directory;
  };

  services.taskserver = {
    enable = true;
    fqdn = "todo.nani.wtf";
    listenPort = 19233;
    dataDir = "${config.machineVars.dataDrives.default}/var/taskserver";

    organisations.h7x4 = {
      groups = [ "users" ];
      users = [ "h7x4" ];
    };

    pki.manual = let
      inherit (config.security.acme.certs."tasks.nani.wtf") directory;
    in {
      server.key = "${directory}/key.pem";
      server.cert = "${directory}/cert.pem";
      ca.cert = "${directory}/chain.pem";
    };
  };

  environment = {
    systemPackages = with pkgs; [ taskserver ];
    variables.TASKDDATA = config.services.taskserver.dataDir;
  };
}
