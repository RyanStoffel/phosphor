{ ... }:
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 24;
        spacing = 4;

        modules-left = [ "niri/workspaces" "niri/window" ];
        modules-center = [];
        modules-right = [
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "battery"
          "clock"
        ];

        "niri/workspaces" = {
          format = "{index}";
        };

        "niri/window" = {
          max-length = 50;
        };

        clock = {
          format = "{:%Y-%m-%d %H:%M}";
          tooltip = false;
        };

        cpu = {
          format = "cpu {usage}%";
          interval = 5;
        };

        memory = {
          format = "mem {percentage}%";
          interval = 10;
        };

        battery = {
          format = "bat {capacity}%";
          format-charging = "bat+ {capacity}%";
          states = {
            warning = 30;
            critical = 15;
          };
        };

        network = {
          format-wifi = "wifi {essid}";
          format-ethernet = "eth";
          format-disconnected = "offline";
          tooltip = false;
        };

        pulseaudio = {
          format = "vol {volume}%";
          format-muted = "muted";
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };
      };
    };
  };
}
