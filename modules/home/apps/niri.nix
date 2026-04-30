{ lib, ... }:
let
  workspaceBinds = builtins.listToAttrs (
    map (n: {
      name = "Mod+${toString n}";
      value.action.focus-workspace = n;
    }) (lib.range 1 9)
  );

  moveWindowBinds = builtins.listToAttrs (
    map (n: {
      name = "Mod+Shift+${toString n}";
      value.action.move-window-to-workspace = n;
    }) (lib.range 1 9)
  );
in
{
  programs.niri = {
    settings = {
      prefer-no-csd = true;

      spawn-at-startup = [
        { argv = [ "waybar" ]; }
        { argv = [ "mako" ]; }
        { argv = [ "systemctl" "--user" "start" "--no-block" "swayidle.service" ]; }
      ];

      outputs = {
        "eDP-1" = {
          background-color = "#000000";
          backdrop-color = "#000000";
          focus-at-startup = true;
        };

        winit = {
          background-color = "#000000";
          backdrop-color = "#000000";
          focus-at-startup = true;
          scale = 1.0;
        };
      };

      layout = {
        gaps = 0;
        background-color = "#000000";
        focus-ring.enable = false;
        shadow.enable = false;
        tab-indicator.corner-radius = 0;
      };

      overview.workspace-shadow.enable = false;

      animations.enable = false;

      binds = workspaceBinds // moveWindowBinds // {
        "Mod+Return" = {
          repeat = false;
          action.spawn = [ "ghostty" ];
        };

        "Mod+Shift+Return" = {
          repeat = false;
          action.spawn = [ "chromium" ];
        };

        "Mod+Space" = {
          repeat = false;
          action.spawn = [ "fuzzel" ];
        };

        "Mod+Q" = {
          repeat = false;
          action.close-window = [ ];
        };

        "Mod+Shift+E" = {
          repeat = false;
          action.quit = [ ];
        };

        "Mod+H".action.focus-column-left = [ ];
        "Mod+Right".action.focus-column-right = [ ];
        "Mod+J".action.focus-window-down = [ ];
        "Mod+K".action.focus-window-up = [ ];

        "Mod+Shift+H".action.move-column-left = [ ];
        "Mod+Shift+Right".action.move-column-right = [ ];

        "Mod+F" = {
          repeat = false;
          action.fullscreen-window = [ ];
        };

        "Mod+Shift+F" = {
          repeat = false;
          action.toggle-window-floating = [ ];
        };

        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";

        "Mod+L" = {
          repeat = false;
          action.spawn = [ "swaylock" ];
        };
      };
    };
  };
}
