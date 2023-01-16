{ ... }:
{
# Material values are 1:1 with in-game IDs. The prepending of "minecraft:" is optional
# To specify states, do so with [brackets]. For example, "minecraft:chest[waterlogged=true]"
# The above will search for any waterlogged chests. Other states will be ignored when checking.
#
# To add a custom category, see the categories.yml
#
# VeinMiner supports 3 different types of storage (SQLite is used by default)
#   JSON: Each player's data is stored in its own JSON file under the specified directory.
#   SQLite: Player data is stored in an SQLite database table. A flat file database. Generally faster than JSON.
#   MySQL: Player data is stored remotely in a MySQL-compliant database (MySQL, MariaDB, etc.). Use this if you want to share VeinMiner data on multiple servers and have a MySQL server available to use

  MetricsEnabled = true;
  PerformUpdateChecks = true;
  
  DefaultActivationStrategy = "SNEAK";
  DefaultVeinMiningPattern = "veinminer:default";
  CollectItemsAtSource = true;
  NerfMcMMO = false;
  
  RepairFriendly = false;
  MaxVeinSize = 64;
  Cost = 0.0;
  
  DisabledGameModes = [
    "CREATIVE"
    "SPECTATOR"
  ];

  DisabledWorlds = [
    "WorldName"
  ];
  
  Hunger = {
    HungerModifier = 4.0;
    MinimumFoodLevel = 1;
    HungryMessage = "&7You are too hungry to vein mine!";
  };
  
  Client = {
    AllowActivationKeybind = true;
    AllowPatternSwitchingKeybind = true;
    AllowWireframeRendering = true;
  };
  
  Storage = {
    # Supported types...
    # JSON: Each player's data is stored in its own JSON file under the specified directory.
    # SQLite: Player data is stored in an SQLite database table. A flat file database. Generally faster than JSON.
    # MySQL: Player data is stored remotely in a MySQL-compliant database (MySQL, MariaDB, etc.). Use this if you want to share VeinMiner data on multiple servers and have a MySQL server available to use.
    Type = "SQLite";
  
    # JSON.Directory = "%plugin%/playerdata/";
  
    # MySQL = {
    #   Host = "localhost";
    #   Port = 3306;
    #   Username = "username";
    #   Password = "password";
    #   Database = "veinminer";
    #   TablePrefix = "veinminer_";
    # };
  };
  
  BlockList = {
    Pickaxe = [
      "minecraft:amethyst_cluster"
      "minecraft:ancient_debris"
      "minecraft:coal_ore"
      "minecraft:copper_ore"
      "minecraft:deepslate_coal_ore"
      "minecraft:deepslate_copper_ore"
      "minecraft:deepslate_diamond_ore"
      "minecraft:deepslate_emerald_ore"
      "minecraft:deepslate_gold_ore"
      "minecraft:deepslate_iron_ore"
      "minecraft:deepslate_lapis_ore"
      "minecraft:deepslate_redstone_ore"
      "minecraft:diamond_ore"
      "minecraft:emerald_ore"
      "minecraft:gold_ore"
      "minecraft:iron_ore"
      "minecraft:lapis_ore"
      "minecraft:nether_quartz_ore"
      "minecraft:nether_gold_ore"
      "minecraft:raw_copper_block"
      "minecraft:raw_gold_block"
      "minecraft:raw_iron_block"
      "minecraft:redstone_ore"
    ];
    Axe = [
      "minecraft:acacia_log"
      "minecraft:acacia_wood"
      "minecraft:birch_log"
      "minecraft:birch_wood"
      "minecraft:brown_mushroom_block"
      "minecraft:carved_pumpkin"
      "minecraft:crimson_hyphae"
      "minecraft:crimson_stem"
      "minecraft:dark_oak_log"
      "minecraft:dark_oak_wood"
      "minecraft:jungle_log"
      "minecraft:jungle_wood"
      "minecraft:mangrove_log"
      "minecraft:mangrove_roots"
      "minecraft:mangrove_wood"
      "minecraft:melon"
      "minecraft:oak_log"
      "minecraft:oak_wood"
      "minecraft:pumpkin"
      "minecraft:red_mushroom_block"
      "minecraft:spruce_log"
      "minecraft:spruce_wood"
      "minecraft:warped_stem"
      "minecraft:warped_hyphae"
    ];
    Shovel = [
      "minecraft:clay"
      "minecraft:gravel"
      "minecraft:mud"
      "minecraft:muddy_mangrove_roots"
      "minecraft:powder_snow"
      "minecraft:sand"
      "minecraft:snow"
      "minecraft:soul_sand"
      "minecraft:soul_soil"
    ];
    Hoe = [
      "minecraft:beetroots[age=3]"
      "minecraft:brown_mushroom"
      "minecraft:carrots[age=7]"
      "minecraft:moss_block"
      "minecraft:moss_carpet"
      "minecraft:potatoes[age=7]"
      "minecraft:red_mushroom"
      "minecraft:sculk"
      "minecraft:sculk_vein"
      "minecraft:wheat[age=7]"
    ];
    Shears = [
      "minecraft:acacia_leaves"
      "minecraft:azalea_leaves"
      "minecraft:birch_leaves"
      "minecraft:black_wool"
      "minecraft:blue_wool"
      "minecraft:brown_wool"
      "minecraft:cobweb"
      "minecraft:cyan_wool"
      "minecraft:dark_oak_leaves"
      "minecraft:flowering_azalea_leaves"
      "minecraft:gray_wool"
      "minecraft:green_wool"
      "minecraft:jungle_leaves"
      "minecraft:light_blue_wool"
      "minecraft:light_gray_wool"
      "minecraft:lime_wool"
      "minecraft:magenta_wool"
      "minecraft:mangrove_leaves"
      "minecraft:oak_leaves"
      "minecraft:orange_wool"
      "minecraft:pink_wool"
      "minecraft:purple_wool"
      "minecraft:red_wool"
      "minecraft:spruce_leaves"
      "minecraft:white_wool"
      "minecraft:yellow_wool"
    ];
    Hand = [];
    All = [
      "minecraft:blue_ice"
      "minecraft:ice"
      "minecraft:packed_ice"
    ];
  };
  
  Aliases = [
    "minecraft:acacia_log;minecraft:acacia_wood"
    "minecraft:birch_log;minecraft:birch_wood"
    "minecraft:brown_mushroom_block;minecraft:red_mushroom_block"
    "minecraft:carved_pumpkin;minecraft:pumpkin"
    "minecraft:crimson_hyphae;minecraft:crimson_stem"
    "minecraft:dark_oak_log;minecraft:dark_oak_wood"
    "minecraft:grass;minecraft:tall_grass"
    "minecraft:jungle_log;minecraft:jungle_wood"
    "minecraft:mangrove_log;minecraft:mangrove_wood"
    "minecraft:oak_log;minecraft:oak_wood"
    "minecraft:spruce_log;minecraft:spruce_wood"
    "minecraft:warped_hyphae;minecraft:warped_stem"
  ];
}
