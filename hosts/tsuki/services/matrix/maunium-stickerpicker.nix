# This is imported directly by the nginx config
{ lib, maunium-stickerpicker, secrets, ... }: let
  stickerpickerWithStickerbot = sha256: packs:
    maunium-stickerpicker.outputs.createStickerPicker {
      homeserver = "https://matrix.nani.wtf";
      userId = "@stickerbot1:nani.wtf";
      accessTokenFile = secrets.settings.keys.matrix.stickerbot-access-token;
      inherit sha256 packs;
    };
in {
  stickers-h7x4 = stickerpickerWithStickerbot
    "+1ccLd+7zN6ZEFSuzb+K+0sn2wOm3EGhL1GNLTh5+5M="
    [
      {
        type = "chatsticker";
        name = "dog-cat-dogboy-side-1";
        title = "Dogboy";
      }
      {
        type = "chatsticker";
        name = "frown-cat-vol-2-1";
        title = "Frown Cat 2";
      }
      {
        type = "url-list";
        src = ./stickers/ninicouple.txt;
        title = "Nini Couple";
      }
      {
        type = "url-list";
        src = ./stickers/sweet-couple.txt;
        title = "Sweet Couple";
      }
    ];

  stickers-pingu = stickerpickerWithStickerbot
    "0m2OoL0jmwGnYUbRBSaHyM4hMLNX2uDlYykdUbqhU4o="
    [
      {
        type = "chatsticker";
        name = "dog-cat-catgirl-side-1";
      }
      {
        type = "chatsticker";
        name = "frown-cat-1";
      }
      {
        type = "url-list";
        src = ./stickers/ninicouple.txt;
        title = "Nini Couple";
      }
      {
        type = "url-list";
        src = ./stickers/sweet-couple.txt;
        title = "Sweet Couple";
      }
    ];
}
