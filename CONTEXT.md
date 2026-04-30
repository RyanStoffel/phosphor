# CONTEXT.md

**Phosphor** — a NixOS-based opinionated Linux desktop distribution inspired by
Omarchy's philosophy: curated, keyboard-driven, beautiful, and immediately productive
out of the box. Built for developers. Ships as an installer ISO.

Name evokes CRT phosphor screens — the oldschool terminal aesthetic that defines
the project's visual identity.

---

## Glossary

### Distribution
The project itself — a NixOS flake that exposes `nixosModules.default` and
`homeManagerModules.default`, distributed as a bootable installer ISO. Not a fork
of NixOS; an opinionated layer on top of it.

### Base System
NixOS (nixos-unstable channel) as the foundational Linux distribution. All
NixOS primitives (generations, rollback, `nixos-rebuild`) are available to users
and are the distribution's update mechanism.

### Compositor
Niri — a scrollable-tiling Wayland compositor. The deliberate departure from
Omarchy's Hyprland. Managed via the `sodiboo/niri-flake` upstream flake, which
provides NixOS and Home Manager modules with build-time config validation.

### Theme
A named Stylix configuration consisting of a hand-crafted base16 `.yaml` scheme
file and a wallpaper definition. Multiple named themes ship with the distribution.
Switching themes means pointing `stylix.base16Scheme` at a different scheme file
and running `distro-update`. Themes are stored inside the distribution's flake
repo under `themes/`.

### Color Scheme
A base16-compatible `.yaml` file defining 16 colors. The distribution ships its
own hand-crafted schemes — not delegating to `pkgs.base16-schemes` — to express
a distinctive oldschool terminal aesthetic: pure black backgrounds, minimal color
palette, phosphor-inspired accent colors.

### Stylix
The Home Manager / NixOS module (`github:danth/stylix`) used to propagate a
single color scheme and font across all themed applications (Ghostty, Waybar,
Vim, Mako, Fuzzel, swaylock, btop, GTK, etc.) declaratively.

### Managed Flake
The user's NixOS configuration flake, located at `~/nixos/flake.nix`. It is
user-owned (no sudo required to edit). It imports the distribution's flake as an
input and applies `nixosModules.default` and `homeManagerModules.default`.
The ISO installs this starter flake on first boot.

### Update Command
A thin shell script installed as a system package (name TBD, matching the
distro name). Runs `nix flake update && sudo nixos-rebuild switch --flake ~/nixos`.
Designed so a guided TUI can wrap it later without changing the underlying
mechanism. NixOS generations serve as the rollback mechanism — no custom
migration system needed.

### Application Stack
The curated, opinionated set of default applications shipped by the distribution.
Users can override any application via standard NixOS module options.

| Category      | Application      | Notes                                              |
|---------------|------------------|----------------------------------------------------|
| Compositor    | Niri             | sodiboo/niri-flake, declarative KDL via HM module  |
| Terminal      | Ghostty          | GPU-accelerated, full Stylix support               |
| Editor        | Vim (plain)      | Custom config shipped by distribution              |
| Browser       | Chromium         | Full Wayland + DRM support; Helium as future goal  |
| Bar           | Waybar           | Best niri support, Stylix-themed                   |
| Launcher      | Fuzzel           | Wayland-native, lightweight, Stylix-themed         |
| Notifications | Mako             | Wayland-native, Stylix-themed                      |
| Lock screen   | swaylock         | niri-flake provides PAM entry automatically        |
| File manager  | Yazi             | TUI, keyboard-driven                               |
| Notes         | Obsidian         | Wayland-native                                     |
| Screenshots   | Flameshot        | Wayland screenshot + annotation                    |
| Media         | Spotify          | Unfree; user must accept unfree packages           |

### Shell
Bash. System-wide default shell. No zsh, no fish — deliberate simplicity.

### Font
IBM Plex Mono (`ibm-plex` in nixpkgs, font name `"IBM Plex Mono"`).
Applied system-wide via `stylix.fonts.monospace`. All four Stylix font
categories (monospace, sansSerif, serif, emoji) are set to IBM Plex Mono
to enforce the terminal aesthetic uniformly.

### Visual Aesthetic
Oldschool terminal. Pure black backgrounds, minimal color palette, no blur,
no transparency, no rounded corners, no animations. Phosphor-inspired accent
colors (green or amber variants as named themes). IBM Plex Mono everywhere.
Wallpaper is a solid color generated via `config.lib.stylix.pixel "base00"` —
no image assets required.

### Installer ISO
A bootable NixOS ISO built via `nixos-rebuild build-image --image-variant iso`
from a dedicated `nixosConfigurations.iso` entry in the distribution's flake.
The ISO installs NixOS and writes the starter `~/nixos/flake.nix` pointing at
the distribution's upstream flake. Disk partitioning handled by `disko`.

### Target User
Software developers comfortable with a keyboard-driven workflow. Familiar with
or willing to learn a terminal-centric environment. Not necessarily NixOS
experts — the distribution abstracts NixOS complexity behind the update command
and opinionated defaults.

### GPU Strategy
AMD is the primary supported GPU vendor for Phosphor's development phase. The
default NixOS module configures AMD graphics via `amdgpu` kernel module and
`hardware.graphics.enable = true` with `enable32Bit = true`. RADV is the default
Vulkan driver — no `amdvlk` overlay needed.

Nvidia support is a separate opt-in module (`phosphor.gpu.nvidia = true`) to be
designed and tested after the AMD baseline is solid. Intel integrated graphics
work without any explicit configuration.

### Gaming Module
An opt-in module enabled via `phosphor.gaming.enable = true`. Not included in
the default application stack — avoids pulling in Steam and 32-bit graphics libs
for users who don't want them.

System-level components (NixOS module, `modules/nixos/gaming.nix`):
- `programs.steam.enable` — Steam with Proton
- `programs.gamescope.enable` — Valve's micro-compositor for HDR/VRR
- `programs.gamemode.enable` — CPU/GPU performance optimizations on game launch
- `hardware.graphics.enable32Bit` — required for Proton/Wine compatibility
- `protonup-qt` — GUI installer for GloriousEggroll's Proton fork (Proton-GE)
- `mangohud` — FPS/temperature overlay
- `hardware.xone.enable` / `hardware.xpadneo.enable` — controller sub-options

User-level components (Home Manager module, opt-in sub-option
`phosphor.gaming.minecraft = true`):
- `prismlauncher` — overridden with correct JDKs and `additionalLibs` for GPU
  access so Minecraft uses the dedicated GPU out of the box
- `modrinth-app` — official Modrinth launcher (compiles from source; must be
  covered by Phosphor's binary cache before public release)
- `heroic` — GOG + Epic Games launcher
- `bottles` — Wine prefix manager
- `lutris` — general game manager

### Developer Tooling (Default)
Universal tools only: `git`, `gh`, `direnv`, `ripgrep`, `fzf`, `bat`, `eza`,
`jq`, `htop`, `btop`. Language runtimes are opt-in via documented module options.

---

## Open Decisions

- **Helium browser** — deferred. No nixpkgs package exists; currently in beta;
  lacks Widevine DRM (incompatible with Spotify). Chromium is the default.
  Revisit when Helium stabilizes and gains a nixpkgs derivation.

- **Vim config** — content not yet designed. Will be shipped as a Home Manager
  `programs.vim` configuration inside `homeManagerModules.default`. Must make
  Vim usable for newcomers without abandoning its character.

- **Named themes** — color values not yet defined. At minimum: one green
  phosphor variant and one amber phosphor variant. Possibly a pure white-on-black
  classic variant.

- **Binary cache** — hosting not yet decided. Required before public distribution
  so users do not compile from source. Cachix is the likely choice.
