{ pkgs, secrets, ... }:
{
  users.users.jupyter = {
    group = "jupyter";
  };

  services.jupyter = {
    enable = true;
    group = "jupyter";
    ip = "0.0.0.0";
    port = secrets.ports.jupyterhub;
    password = secrets.keys.hashed.jupyter;
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
}
