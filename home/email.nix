{ config, lib, pkgs, ... }:
let
  cfg = config.accounts.email;
in
{
  sops.secrets = {
    "email/naniwtf/password" = { };
    "email/kyoto-u/password" = { };
    "email/pvv/password" = { };
  };

  accounts.email = {
    maildirBasePath = "mail";
    accounts = {
      "naniwtf" = let
        userName = "h7x4";
        domain = "nani.wtf";
      in {
        primary = true;

        userName = "${userName}@${domain}";
        realName = "h7x4";
        address = "${userName}@${domain}";
        passwordCommand = "${lib.getExe' pkgs.coreutils "cat"} ${config.sops.secrets."email/naniwtf/password".path}";

        imap = {
          host = "redbull.mxrouting.net";
          port = 993;
          authentication = "plain";
          tls.enable = true;
        };

        smtp = {
          host = "redbull.mxrouting.net";
          port = 465;
          authentication = "plain";
          tls.enable = true;
        };

        gpg = {
          key = "46B9228E814A2AAC";
          signByDefault = true;
        };

        neomutt.enable = true;
        thunderbird.enable = true;
        meli.enable = true;
      };

      "pvv" = let
        userName = "oysteikt";
        domain = "pvv.ntnu.no";
      in {
        inherit userName;
        realName = "Øystein K Tveit";
        address = "${userName}@${domain}";
        passwordCommand = "${lib.getExe' pkgs.coreutils "cat"} ${config.sops.secrets."email/pvv/password".path}";

        imap = {
          host = "imap.${domain}";
          port = 993;
          authentication = "plain";
          tls.enable = true;
        };

        smtp = {
          host = "redbull.mxrouting.net";
          port = 587;
          authentication = "plain";
          tls = {
            enable = true;
            useStartTls = true;
          };
        };

        gpg = {
          key = "";
          signByDefault = true;
        };

        neomutt.enable = true;
        thunderbird.enable = true;
        meli.enable = true;
      };

      "kyoto-u" = let
        userName = "oysteikt";
        domain = "fos.kuis.kyoto-u.ac.jp";
      in {
        inherit userName;
        realName = "トバイト、オースティン";
        address = "${userName}@${domain}";
        passwordCommand = "${lib.getExe' pkgs.coreutils "cat"} ${config.sops.secrets."email/kyoto-u/password".path}";

        imap = {
          host = "io.kuis.kyoto-u.ac.jp";
          port = 993;
          authentication = "plain";
          tls.enable = true;
        };

        smtp = {
          host = "io.kuis.kyoto-u.ac.jp";
          port = 587;
          authentication = "plain";
          tls = {
            enable = true;
            useStartTls = true;
          };
        };

        # gpg = {

        # };

        neomutt.enable = true;
        thunderbird.enable = true;
        meli.enable = true;
      };
    };
  };

  systemd.user.tmpfiles.settings."10-maildir" = lib.mkIf (lib.any (acct: acct.enable) (lib.attrValues cfg.accounts)) {
    "${config.home.homeDirectory}/${cfg.maildirBasePath}".d =  {
      mode = "0700";
      user = config.home.username;
    };
  };
}
