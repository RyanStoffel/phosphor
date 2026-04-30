{ pkgs, lib, config, ... }:
let
  cfg = config.phosphor.gaming;
in
{
  options.phosphor.gaming = {
    enable = lib.mkEnableOption "gaming support (Steam, GameMode, Gamescope, MangoHud)";

    minecraft = lib.mkEnableOption "Minecraft launchers (Prism Launcher, Modrinth App)";

    controllers = {
      xbox = lib.mkEnableOption "Xbox wireless controller dongle support (xone)";
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      steam = {
        enable = true;
        gamescopeSession.enable = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };

      gamescope = {
        enable = true;
        capSysNice = true;
      };

      gamemode.enable = true;
    };

    hardware.xone.enable = cfg.controllers.xbox;

    environment.systemPackages = with pkgs; [
      mangohud
      protonup-qt
      heroic
      bottles
      lutris
    ] ++ lib.optionals cfg.minecraft [
      (prismlauncher.override {
        jdks = [ pkgs.jdk21 pkgs.jdk17 pkgs.jdk8 ];
        additionalLibs = with pkgs; [
          libGL
          vulkan-loader
        ];
      })
      modrinth-app
    ];

  };
}
