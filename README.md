# Phosphor

An opinionated NixOS desktop distribution. Black screens. Green phosphor.
IBM Plex Mono everywhere. Keyboard-driven. Built for developers who also game.

Built on NixOS + Niri + Stylix.

---

## Development Setup

### Prerequisites

- Nix with flakes enabled (works on macOS via Nix-Darwin or on NixOS)
- Claude Code: `npm install -g @anthropic-ai/claude-code`

### Repository structure

```
phosphor/
├── flake.nix                  # root flake — all inputs wired here
├── modules/
│   ├── nixos/                 # system-level NixOS modules
│   │   ├── core.nix           # users, fonts, nix settings, Stylix
│   │   ├── desktop.nix        # niri, portals, Wayland env vars
│   │   ├── packages.nix       # universal dev tools
│   │   └── gaming.nix         # opt-in: Steam, GameMode, Minecraft
│   └── home/                  # Home Manager modules
│       ├── shell/bash.nix
│       └── apps/              # one file per application
├── themes/
│   ├── phosphor-green.yaml    # default theme
│   └── phosphor-amber.yaml
├── hosts/dev/                 # your personal test host
├── iso/                       # installer ISO configuration
├── CONTEXT.md                 # project glossary and decisions
└── docs/adr/                  # architecture decision records
```

### Building and testing in a VM

```bash
# Build a QEMU VM for testing (works on Linux host)
nix build .#nixosConfigurations.dev.config.system.build.vm
./result/bin/run-phosphor-dev-vm

# Or switch your actual system (if running NixOS)
sudo nixos-rebuild switch --flake .#dev
```

### Building the installer ISO

```bash
nixos-rebuild build-image --image-variant iso --flake .#iso
# or
nix build .#nixosConfigurations.iso.config.system.build.isoImage
```

### Working with Claude Code

```bash
cd phosphor/
claude  # start a session with full repo context
```

Hand Claude Code individual module tasks:
- "Write the niri config module in modules/home/apps/niri.nix"
- "Add a phosphor.gpu.nvidia option to modules/nixos/core.nix"
- "Design the phosphor-update script as a system package"

---

## User Installation (future)

1. Boot the Phosphor ISO
2. Follow the installer — it writes `~/nixos/flake.nix` pointing at this repo
3. Run `phosphor-update` to apply changes

## Updating (for installed users)

```bash
phosphor-update
```

This runs `nix flake update ~/nixos && sudo nixos-rebuild switch --flake ~/nixos`.
Roll back with `phosphor-rollback` if anything goes wrong.

---

## Themes

Switch themes by changing `stylix.base16Scheme` in your `~/nixos/flake.nix`:

```nix
stylix.base16Scheme = "${inputs.phosphor}/themes/phosphor-amber.yaml";
```

Then run `phosphor-update`.

Available themes: `phosphor-green` (default), `phosphor-amber`.

## Gaming

Enable the gaming module in your host config:

```nix
phosphor.gaming.enable = true;
phosphor.gaming.minecraft = true;
phosphor.gaming.controllers.xbox = true;
```
