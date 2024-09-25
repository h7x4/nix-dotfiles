{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nrfutil
    nrfconnect
    nrf-command-line-tools
  ];

  services.udev.packages = with pkgs; [
    nrf-udev
    segger-jlink
  ];
}