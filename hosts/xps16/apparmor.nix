{ pkgs, ... }:
{
  security.apparmor = {
    enable = true;
    packages = with pkgs; [ apparmor-profiles ];
    policies.firefox.path = "${pkgs.apparmor-profiles}/etc/apparmor.d/firefox";
  };
}
