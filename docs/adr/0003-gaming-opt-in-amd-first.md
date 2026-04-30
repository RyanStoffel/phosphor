# ADR-0003: Gaming as an opt-in module with AMD-first GPU support

Date: 2026-04-29
Status: Accepted

## Context

Phosphor targets developers, but gaming is a first-class use case. The question
is whether gaming tooling (Steam, 32-bit graphics libs, GameMode, Gamescope)
should be on by default or opt-in.

Including it by default means every Phosphor install pulls in Steam and 32-bit
Mesa libs even for users who never game. This adds significant closure size and
complexity with no benefit for pure dev users.

Additionally, GPU driver configuration is hardware-specific and cannot be
defaulted safely across all machines. Nvidia in particular requires meaningfully
different configuration from AMD and would cause boot failures if applied to AMD
hardware.

The primary developer machine is AMD, making it the natural first-class supported
GPU vendor for the initial development phase.

## Decision

Gaming is an opt-in module enabled via `phosphor.gaming.enable = true`. It is
not included in the default Phosphor configuration.

AMD is the primary supported GPU vendor. The default Phosphor hardware module
configures `amdgpu` and `hardware.graphics` for AMD. Nvidia support is a
separate opt-in module (`phosphor.gpu.nvidia = true`) to be added after the AMD
baseline is complete and tested.

The gaming module exposes sub-options:
- `phosphor.gaming.enable` — enables Steam, GameMode, Gamescope, MangoHud
- `phosphor.gaming.minecraft` — adds Prism Launcher and Modrinth App
- `phosphor.gaming.controllers.xbox` — enables xone kernel module for Xbox
  wireless dongles

## Consequences

- Default Phosphor installs are lean — no unexpected 32-bit lib pulls.
- Users who want gaming add one line to their `~/nixos/flake.nix`.
- Nvidia users must explicitly opt into Nvidia configuration — prevents silent
  misconfiguration on AMD hardware.
- Modrinth App compiles from source unless covered by Phosphor's binary cache.
  This must be resolved before public release.
- Prism Launcher is shipped with `additionalLibs` configured for GPU access to
  prevent the known NixOS issue of Minecraft defaulting to software rendering.
