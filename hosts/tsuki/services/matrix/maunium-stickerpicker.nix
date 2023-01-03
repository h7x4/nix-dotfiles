# This is imported directly by the nginx config
{ lib, maunium-stickerpicker }: let
  inherit (maunium-stickerpicker.outputs) createStickerPickerWithStickers;
  inherit (maunium-stickerpicker.outputs.fetchers) fetchFromChatStickers;
in {
  stickers-h7x4 = createStickerPickerWithStickers {
    homeserver = "https://matrix.nani.wtf";
    userId = "@stickerbot1:nani.wtf";
    accessToken = "syt_c3RpY2tlcmJvdDE_KMDwLEdAdPswTXPhCoeN_3FSt8B";
    packs = [
      {
        title = "Dogboy";
        sha256 = "RTyxgVzwUPSyPLeiFp7bQ4X5DgEaHB/+dPPPc5w2Cfw=";
        src = fetchFromChatStickers {
          name = "dog-cat-dogboy-side-1";
          sha256 = "PNqTMxm7iUFxObkAZURHxMxBMmUerugoRTA4IsO1aJ8=";
        };
      }
      {
        title = "Frown Cat 2";
        sha256 = "pNFtjoxSRLDsL9UxwX/crRcx6qHNKmXhhYU7+ygEJHE=";
        src = fetchFromChatStickers {
          name = "frown-cat-vol-2-1";
          sha256 = "E2n9PfL8pxIalam7+89emqCfKsoa/emNiBS93b0q9Ro=";
        };
      }
    ];
  }; 
  stickers-pingu = createStickerPickerWithStickers {
    homeserver = "https://matrix.nani.wtf";
    userId = "@stickerbot1:nani.wtf";
    accessToken = "syt_c3RpY2tlcmJvdDE_KMDwLEdAdPswTXPhCoeN_3FSt8B";
    packs = [
      {
        title = "Catgirl";
        sha256 = "UBU1cNYDnhPjStHGVNcTa8MpLeYHr1qn7Ea1jmB1hJ0=";
        src = fetchFromChatStickers {
          name = "dog-cat-catgirl-side-1";
          sha256 = "HNU49j9ju+UH8AiN0/sQIMgTNfNuZ/Xbpli2yisighg=";
        };
      }
      {
        title = "Frown Cat 1";
        sha256 = "uJ6O7fDLBS/I9EiU1oIieDzbyrr9IPbaWF5pGDmwYZo=";
        src = fetchFromChatStickers {
          name = "frown-cat-1";
          sha256 = "rapDLBSWvxrvbp4E4/zzUM0IU6OALdAk1jA/1PP3LhY=";
        };
      }
    ];
  }; 
}
