{ ... }:
{
  messages = {
    prefix = "$8[$bSilkSpawners$8]";
    lcoale = "en";
  };

  spawner = {
    destroyable = true;
    item = {
      name = "$dSpawner";
      prefix = "$e";
      prefix-old = "";
      lore = [];
    };
    explosion = {
      normal = 0;
      silktouch = 0;
    };
    message = {
      denyDestroy = true;
      denyPlace = true;
      denyChange = true;
    };
  };

  update.check = {
    enabled = true;
    interval = 24;
  };
}
