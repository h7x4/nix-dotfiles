{ pkgs, lib, config, inputs, secrets, ... }:
{
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    dataDir = "${config.machineVars.dataDrives.default}/var/minecraft";
    servers.kakuland = {
      enable = true;

      serverProperties = {
        allow-flight = true;
        allow-nether = true;
        broadcast-console-to-ops = true;
        broadcast-rcon-to-ops = true;
        debug = false;
        difficulty = "easy";
        enable-command-block = false;
        enable-jmx-monitoring = false;
        enable-query = false;
        enable-rcon = false;
        enable-status = true;
        enforce-secure-profile = false;
        enforce-whitelist = false;
        entity-broadcast-range-percentage = 100;
        force-gamemode = false;
        function-permission-level = 2;
        gamemode = "survival";
        generate-structures = true;
        # generator-settings={}
        hardcore = false;
        hide-online-players = false;
        level-name = "world";
        # level-seed = 
        level-type = "default";
        max-chained-neighbor-updates = 1000000;
        max-players = 2;
        max-tick-time = 60000;
        max-world-size = 29999984;
        motd = "Yaba Saba";
        network-compression-threshold = 256;
        online-mode = true;
        op-permission-level = 4;
        player-idle-timeout = 0;
        prevent-proxy-connections = false;
        previews-chat = false;
        pvp = true;
        # "query.port" = 25565;
        rate-limit = 0;
        # rcon.password=
        # rcon.port=25575
        require-resource-pack = false;
        # resource-pack=
        # resource-pack-prompt=
        # resource-pack-sha1=
        server-ip = "0.0.0.0";
        server-port = 25565;
        simulation-distance = 10;
        spawn-animals = true;
        spawn-monsters = true;
        spawn-npcs = true;
        spawn-protection = 16;
        sync-chunk-writes = true;
        # text-filtering-config=
        use-native-transport = true;
        view-distance = 10;
        white-list = true;
      };

      package = inputs.minecraft.packages.x86_64-linux.paper-server;

      # See https://docs.papermc.io/paper/aikars-flags
      jvmOpts = lib.concatStringsSep " " [
        "-Xms5G"
        "-Xmx15G"
        "-XX:+UseG1GC"
        "-XX:+ParallelRefProcEnabled"
        "-XX:MaxGCPauseMillis=200"
        "-XX:+UnlockExperimentalVMOptions"
        "-XX:+DisableExplicitGC"
        "-XX:+AlwaysPreTouch"
        "-XX:G1NewSizePercent=30"
        "-XX:G1MaxNewSizePercent=40"
        "-XX:G1HeapRegionSize=8M"
        "-XX:G1ReservePercent=20"
        "-XX:G1HeapWastePercent=5"
        "-XX:G1MixedGCCountTarget=4"
        "-XX:InitiatingHeapOccupancyPercent=15"
        "-XX:G1MixedGCLiveThresholdPercent=90"
        "-XX:G1RSetUpdatingPauseTimePercent=5"
        "-XX:SurvivorRatio=32"
        "-XX:+PerfDisableSharedMem"
        "-XX:MaxTenuringThreshold=1"
        "-Dusing.aikars.flags=https://mcflags.emc.gs"
        "-Daikars.new.flags=true"
      ];

      symlinks = let
        rawFile = file: pkgs.runCommandLocal (builtins.baseNameOf file) {} ''
          ln -s ${file} $out
        '';

        yamlFormat = pkgs.formats.yaml {};
        yamlConfig = name: file: env:
          yamlFormat.generate "minecraft-server-plugin-${name}-configuration.yml" (import file env);
      in {
        "server-icon.png" = rawFile ./extraFiles/server-icon.png;

        "plugins/dynmap/configuration.txt" = 
          yamlConfig "dynmap" ./pluginConfigs/dynmap.nix { inherit secrets; };

        "plugins/VeinMiner/config.yml" =
          yamlConfig "VeinMiner" ./pluginConfigs/veinMiner.nix { };

        "plugins/SmoothTimber/config.yml" =
          yamlConfig "SmoothTimber" ./pluginConfigs/smoothTimber.nix { };

        "plugins/SilkSpawners/config.yml" =
          yamlConfig "SilkSpawners" ./pluginConfigs/silkSpawners.nix { };

        "plugins/OnePlayerSleep/config.yml" =
          yamlConfig "OnePlayerSleep" ./pluginConfigs/onePlayerSleep.nix { };

        "plugins/ServerBackup/config.yml" =
          yamlConfig "ServerBackup" ./pluginConfigs/serverBackup.nix { };
      };
    };
  };

  services.postgresql = let
    o = lib.optional;
    db = name: {
      inherit name;
      ensurePermissions = {
        "DATABASE \"${name}\"" = "ALL PRIVILEGES";
      };
    };
  in {
    enable = true;

    ensureDatabases = 
      (o config.services.minecraft-servers.enable "dynmap");
    ensureUsers =
      (o config.services.minecraft-servers.enable (db "dynmap"));
  };

  systemd.services.minecraft-server-kakuland.requires = [ "postgresql.service" ];
  systemd.services.minecraft-server-kakuland.after = [
    "postgresql.service"
    "data2-momiji.mount"
  ];
}
