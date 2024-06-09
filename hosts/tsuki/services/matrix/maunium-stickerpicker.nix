{ config, pkgs, lib, ... }: let
  stickerpacks = pkgs.callPackage ./stickers { };
in {
  services.maunium-stickerpicker = {
    enable = true;
    instances."pingu" = {
      realMatrixDomain = "matrix.nani.wtf";
      stickerMatrixDomain = "pingu-stickers.nani.wtf";
      # These will be defined by `useACMECert` in nginx config
      enableACME = false;
      stickerPacks = with stickerpacks; [
        dogCatCatgirlSide
        frownCat1
        niniCouple1
        niniCouple2
        sweetCouple1
        pokemonPiplup
        hutao
      ];
    };

    instances."h7x4" = {
      realMatrixDomain = "matrix.nani.wtf";
      stickerMatrixDomain = "h7x4-stickers.nani.wtf";
      enableACME = false;
      stickerPacks = with stickerpacks; [
        dogCatDogboySide
        niniCouple1
        niniCouple2
        sweetCouple1
        frownCat2
        pokemonPiplup
        hololiveENGura
        misc
      ];
    };
  };
}
