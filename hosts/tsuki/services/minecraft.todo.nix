{ pkgs, lib, ... }:

# See https://github.com/InfinityGhost/nixos-workstation/blob/master/minecraft-server.nix

let
  allocatedMemory = "4096M";
in {
  services.minecraft-server = let
    version = "1.18.1";

    spigot = pkgs.minecraft-server.overrideAttrs (old: {
      src = pkgs.fetchurl {
        url = "https://hub.spigotmc.org/jenkins/job/BuildTools/141/artifact/target/BuildTools.jar";
        sha1 = "?";
      };

      buildPhase = ''
        cat > minecraft-server << EOF

        #!${pkgs.bash}/bin/sh
        exec ${pkgs.adoptopenjdk-jre-hotspot-bin-17}/bin/java \$@ -jar $out/bin/spigot-${version}.jar nogui

        java -jar $src --rev ${version}
      '';

      installPhase = ''
        mkdir -p $out/bin $out/lib/minecraft
        cp -v spigot-${version}.jar $out/lib/minecraft
        cp -v minecraft-server $out/bin

        chmod +x $out/bin/minecraft-server
      '';
    });
  in {
    enable = true;
    eula = true;
    package = pkgs.spigot;
    declarative = true;
    dataDir = "/home/h7x4/minecraft";
    openFirewall = true;

    jvmOpts = lib.concatStringsSep " " [
      "-Xmx${allocatedMemory}"
      "-Xms${allocatedMemory}"
      "-XX:+UseG1GC"
      "-XX:ParallelGCThreads=2"
      "-XX:MinHeapFreeRatio=5"
      "-XX:MaxHeapFreeRatio=10"
    ];

    serverProperties = {
      motd = "NixOS Minecraft Server";
      server-port = 25565;
      difficulty = 2;
      gamemode = 0;
      max-players = 5;
      white-list = false;
      enable-rcon = false;
      allow-flight = true;
    };
    
    # whitelist = {};
  };
}
