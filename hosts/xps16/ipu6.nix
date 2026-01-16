{ config, pkgs, lib, ... }:
let
  cfg = config.hardware.ipu6;
in
{
  hardware.ipu6 = {
    enable = true;
    platform = "ipu6epmtl";
  };

  hardware.firmware = lib.optionals cfg.enable (with pkgs; [
    ipu6-camera-bins
    ivsc-firmware
  ]);

  services.udev.extraRules = lib.mkIf cfg.enable ''
    SUBSYSTEM=="intel-ipu6-psys", MODE="0660", GROUP="video"
  '';

  boot.extraModulePackages = lib.optionals cfg.enable (with config.boot.kernelPackages; [ ipu6-drivers ]);

  environment.systemPackages = lib.optionals cfg.enable (with pkgs; [
    libcamera
  ]);

  # https://jgrulich.cz/2024/08/19/making-pipewire-default-option-for-firefox-camera-handling/
  services.pipewire.wireplumber.extraConfig."disable-v4l2" = lib.mkIf cfg.enable {
    "wireplumber.profiles" = {
      "main" = {"monitor.v4l2" = "disabled";};
    };
  };

  # See also: https://github.com/NixOS/nixpkgs/issues/225743
}
