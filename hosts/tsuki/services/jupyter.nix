{ config, pkgs, lib, ... }: let
  cfg = config.services.jupyter;
in {
  sops.secrets."jupyter/password" = {
    restartUnits = [ "jupyter.service" ];
    owner = cfg.user;
    inherit (cfg) group;
  };

  users.users."jupyter".group = "jupyter";

  services.jupyter = {
    enable = true;
    group = "jupyter";
    password = let
      readFile = f: "open('${f}', 'r', encoding='utf8').read().strip()";
    in
      readFile config.sops.secrets."jupyter/password".path;
      
    kernels = {
      pythonDS = let
        env = (pkgs.python3.withPackages (pythonPackages: with pythonPackages; [
          numpy
          matplotlib
          ipykernel
        ]));
      in {
        displayName = "Python for data science";
        argv = [
          "${env.interpreter}"
          "-m"
          "ipykernel_launcher"
          "-f"
          "{connection_file}"
        ];
        language = "python";
        logo32 = "${env}/${env.sitePackages}/ipykernel/resources/logo-32x32.png";
        logo64 = "${env}/${env.sitePackages}/ipykernel/resources/logo-64x64.png";
      };
    }; 
  };

  systemd.services.jupyter = let
    notebookConfig = pkgs.writeText "jupyter_config.py" ''
      c.NotebookApp.notebook_dir = 'notebooks'
      c.NotebookApp.open_browser = False
      c.NotebookApp.password = ${cfg.password}
      c.NotebookApp.password_required = True

      c.NotebookApp.sock = '/run/jupyter/jupyter.sock'
      c.NotebookApp.sock_mode = '0660'
      c.NotebookApp.local_hostnames = ['py.nani.wtf']

      c.ConnectionFileMixin.transport = 'ipc'

      ${cfg.notebookConfig}
    '';
  in {
    environment = {
      JUPYTER_DATA_DIR = "$STATE_DIRECTORY/data";
      JUPYTER_RUNTIME_DIR = "$RUNTIME_DIRECTORY";
    };
    serviceConfig = {
      RuntimeDirectory = "jupyter";
      StateDirectory = "jupyter";

      # Hardening
      CapabilityBoundingSet = "";
      LockPersonality = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateMounts = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      RemoveIPC = true;
      RestrictSUIDSGID = true;
      UMask = "0007";
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
      SystemCallArchitectures = "native";

      ExecStartPre = ''
        ${pkgs.coreutils}/bin/mkdir -p /var/lib/jupyter/{notebooks,data}
      '';
      ExecStart = lib.mkForce ''
        ${cfg.package}/bin/${cfg.command} --NotebookApp.config_file=${notebookConfig}
      '';
    };
  };

  local.socketActivation.jupyter = {
    enable = cfg.enable;
    originalSocketAddress = "/run/jupyter/jupyter.sock";
    newSocketAddress = "/run/jupyter.sock";
    privateNamespace = false;
  };

  systemd.services.jupyter-proxy.serviceConfig = {
    User = "jupyter";
    Group = "jupyter";
  };
}
