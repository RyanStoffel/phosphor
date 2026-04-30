{ config, pkgs, inputs, ... }:
{
  imports = [];

  phosphor = {
    username = "your-username";
    hostname = "phosphor-dev";
  };

  home-manager.users.${config.phosphor.username} = { ... }: {
    home.stateVersion = "25.05";
    home.username = config.phosphor.username;
    home.homeDirectory = "/home/${config.phosphor.username}";
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.networkmanager.enable = true;
}
