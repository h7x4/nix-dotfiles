{ config, pkgs, lib, ... }:
{
  misc = {
    id = "misc";
    title = "Misc";
    stickers = [
      {
        id = "nixos";
        title = "Nixos Logo";
        path = ./misc/nixos.png;
      }
    ];
  };

  dogCatDogboySide = {
    id = "dog-cat-dogboy-side";
    title = "Dog Cat Dogboy Side";
    stickers = ./json/dog-cat-dogboy-side.json;
    hash = "sha256-EVGDR/8xlTnba0YHm/c2CTuwJHFC8BHHBNMnGx+aoQU=";
  };

  dogCatCatgirlSide = {
    id = "dog-cat-catgirl-side";
    title = "Dog Cat Catgirl Side";
    stickers = ./json/dog-cat-catgirl-side.json;
    hash = "sha256-bvp/bNVbSmatD30xJpJLEW5cO0sRudcHbb5lVI69Z/A=";
  };

  niniCouple1 = {
    id = "ninicouple-1";
    title = "Nini Couple 1";
    stickers = ./json/nini-couple-1.json;
    hash = "sha256-S8QP2KVzF1bCUC7lVJP2dEbuVilxTqtQs9/3Q+kPMjM=";
    outputType = "png";
  };

  niniCouple2 = {
    id = "ninicouple-2";
    title = "Nini Couple 2";
    stickers = ./json/nini-couple-2.json;
    hash = "sha256-vZa3S2LIj4vUsX2edy9zGXA5GkOqzbBk82yD+8PqFcw=";
    outputType = "png";
  };

  sweetCouple1 = {
    id = "sweet-couple-1";
    title = "Sweet Couple 1";
    stickers = ./json/sweet-couple-1.json;
    hash = "sha256-dZDRgkCS29wW+/1su9i/3O/MtcRSChwu4DLKj5UooAw=";
    outputType = "png";
  };

  frownCat1 = {
    id = "frown-cat-1";
    title = "Frown Cat 1";
    stickers = ./json/frown-cat-1.json;
    hash = "sha256-BGtSA2Zd1Em3QuooSvO8d6+gNnsJzxIJRRvokWyYu8Y=";
    outputType = "png";
  };

  frownCat2 = {
    id = "frown-cat-2";
    title = "Frown Cat 2";
    stickers = ./json/frown-cat-2.json;
    hash = "sha256-loVBgwudKMxL8/wxO9tBrKzkH9X4TWPa0JdmnJw8pWo=";
    outputType = "png";
  };

  hololiveENGura = {
    id = "hololive-en-gura";
    title = "Hololive EN Gura";
    stickers = ./json/hololive-en-gura.json;
    hash = "sha256-3PHaYCKG3/s674PApgaE/bTF7OU5eKndywPxnsCEpA0=";
    outputType = "png";
  };

  hutao = {
    id = "hutao";
    title = "Hu Tao";
    stickers = ./json/hutao.json;
    hash = "sha256-953otzYwn6/iOeLYGoMA+wpnH8S7nNqTs/XCLU1eM0E=";
  };

  pokemonPiplup = {
    id = "pokemon-piplup";
    title = "Pokemon Piplup";
    stickers = ./json/pokemon-piplup.json;
    hash = "sha256-F2ugOHZbCLxArXzja57+GA2dzUg7XwhGXr+SLLksVqY=";
    outputType = "png";
  };
}
