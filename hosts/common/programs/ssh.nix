{ config, ... }:
{
  sops.secrets."ssh/secret-config" = {
    sopsFile = ./../../../secrets/common.yaml;
    mode = "0444";
  };

  programs.ssh = {
    extraConfig = ''
      Include ${config.sops.secrets."ssh/secret-config".path}
    '';

    knownHosts = {
      hildring = {
        hostNames = [
          "hildring.pvv.ntnu.no"
          "hildring.pvv.org"
          "login.pvv.ntnu.no"
          "login.pvv.org"
        ];
        publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGurF7rdnrDP/VgIK2Tx38of+bX/QGCGL+alrWnZ1Ca5llGneMulUt1RB9xZzNLHiaWIE+HOP0i4spEaeZhilfU=";
      };
      isvegg = {
        hostNames = [
          "isvegg.pvv.ntnu.no"
          "isvegg.pvv.org"
        ];
        publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGurF7rdnrDP/VgIK2Tx38of+bX/QGCGL+alrWnZ1Ca5llGneMulUt1RB9xZzNLHiaWIE+HOP0i4spEaeZhilfU=";
      };
    };
  };
}
