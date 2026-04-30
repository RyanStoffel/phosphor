{ config, ... }:
{
  imports = [
    ./shell/bash.nix
    ./apps/ghostty.nix
    ./apps/vim.nix
    ./apps/niri.nix
    ./apps/waybar.nix
    ./apps/fuzzel.nix
    ./apps/mako.nix
    ./apps/swayidle.nix
    ./apps/yazi.nix
    ./apps/chromium.nix
    ./apps/swaylock.nix
  ];

  gtk.gtk4.theme = config.gtk.theme;
}
