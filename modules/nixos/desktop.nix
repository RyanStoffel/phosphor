{ config, lib, pkgs, ... }:
{
  programs.niri = {
    enable = true;
  };

  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${lib.getExe pkgs.tuigreet} --time --cmd ${lib.getExe' config.programs.niri.package "niri-session"}";
          user = "greeter";
        };
      };
    };

    dbus.enable = true;
  };

  xdg.portal = {
    enable = true;
    config.common.default = "*";
  };

  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      GDK_BACKEND = "wayland,x11";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
    };

    systemPackages = with pkgs; [
      xwayland-satellite
      libnotify
      wl-clipboard
      brightnessctl
      playerctl
    ];
  };
}
