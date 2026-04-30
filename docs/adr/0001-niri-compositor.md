# ADR-0001: Niri as compositor instead of Hyprland

Date: 2026-04-29
Status: Accepted

## Context

The distribution is inspired by Omarchy, which uses Hyprland as its Wayland
compositor. Hyprland has excellent NixOS and Home Manager module support and a
large community. However, the project brief explicitly called for differentiation
from Omarchy rather than a direct port.

Niri is a scrollable-tiling Wayland compositor — a fundamentally different
paradigm from Hyprland's dynamic tiling. Windows scroll horizontally in columns
rather than being split into fixed workspaces. It has a dedicated NixOS/Home
Manager module via `sodiboo/niri-flake` with a notable advantage: configuration
is validated at build time against the KDL schema, meaning broken configs are
caught at `nix build` rather than at runtime.

## Decision

Use Niri as the compositor via `sodiboo/niri-flake`.

## Consequences

- The distribution has a meaningfully different UX from Omarchy — not a clone.
- Build-time config validation gives a better developer experience when
  maintaining the distribution's niri config.
- The `sodiboo/niri-flake` binary cache (niri.cachix.org) means users do not
  compile niri from source.
- Hyprland-specific tooling (Hyprlock, Hypridle, Hyprpicker, Walker) is not
  available. Equivalents must be chosen from the Wayland ecosystem (swaylock,
  swayidle, Fuzzel).
- Niri's scrollable tiling model is less familiar to users coming from macOS
  or traditional desktop environments. Onboarding documentation must address
  this explicitly.
