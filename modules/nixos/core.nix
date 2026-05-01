{ pkgs, lib, config, ... }:
{
  options.phosphor = {
    username = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The primary user account name.";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = "phosphor";
      description = "System hostname.";
    };
  };

  config = {
    networking.hostName = lib.mkDefault config.phosphor.hostname;

    time.timeZone = lib.mkDefault "UTC";
    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
        substituters = [
          "https://cache.nixos.org"
          "https://niri.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        ];
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };

    nixpkgs.config.allowUnfree = true;

    users.defaultUserShell = pkgs.bashInteractive;

    users.users = lib.optionalAttrs (config.phosphor.username != null) {
      "${config.phosphor.username}" = {
        isNormalUser = true;
        extraGroups = [ "wheel" "video" "audio" "networkmanager" "gamemode" ];
        shell = pkgs.bashInteractive;
      };
    };

    security = {
      rtkit.enable = true;
      polkit.enable = true;
      sudo.wheelNeedsPassword = lib.mkDefault true;
    };

    services = {
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
      blueman.enable = true;
    };

    hardware = {
      bluetooth.enable = true;
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };

    boot.initrd.kernelModules = [ "amdgpu" ];

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [ ibm-plex ];
      fontconfig.defaultFonts = {
        monospace = [ "IBM Plex Mono" ];
        sansSerif = [ "IBM Plex Mono" ];
        serif = [ "IBM Plex Mono" ];
        emoji = [ "IBM Plex Mono" ];
      };
    };

    stylix = {
      enable = true;
      polarity = "dark";
      image = config.lib.stylix.pixel "base00";
      base16Scheme = ./../../themes/phosphor-green.yaml;
      fonts = {
        monospace = {
          package = pkgs.ibm-plex;
          name = "IBM Plex Mono";
        };
        sansSerif = {
          package = pkgs.ibm-plex;
          name = "IBM Plex Mono";
        };
        serif = {
          package = pkgs.ibm-plex;
          name = "IBM Plex Mono";
        };
        emoji = {
          package = pkgs.ibm-plex;
          name = "IBM Plex Mono";
        };
        sizes = {
          terminal = 13;
          applications = 12;
          desktop = 12;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      git
      curl
      wget
    ];

    system.stateVersion = "25.05";
  };
}
