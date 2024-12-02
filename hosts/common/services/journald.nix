{ ... }:
{
  services.journald.extraConfig = ''
    MaxFileSec=30day
  '';
}