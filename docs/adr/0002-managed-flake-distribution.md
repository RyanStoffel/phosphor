# ADR-0002: Managed flake in home directory as distribution model

Date: 2026-04-29
Status: Accepted

## Context

Three distribution models were considered:

1. **Flake input model** — users import the distro's flake as an input to their
   own flake. Most composable, most NixOS-native, but requires NixOS knowledge
   to set up.

2. **Fork model** — users clone the repo and run `nixos-rebuild switch`. Simple
   but makes receiving upstream updates and maintaining customizations difficult.

3. **Installer ISO + managed flake** — the ISO installs NixOS and writes a
   starter `~/nixos/flake.nix` that imports the distro's flake as an input.
   Updates via a named wrapper command. Closest to Omarchy's user experience.

The primary goal is a public distribution where the installation and update
experience is as simple as possible. The target user is a developer, not
necessarily a NixOS expert.

## Decision

Use the Installer ISO + managed flake model:

- The distribution's flake repo exposes `nixosModules.default` and
  `homeManagerModules.default`.
- The ISO installs NixOS and writes `~/nixos/flake.nix` (user-owned, no sudo
  to edit) with the distro's flake as a pinned input.
- A named update command wraps `nix flake update && sudo nixos-rebuild switch
  --flake ~/nixos`.
- NixOS generations provide rollback — no custom migration system needed.
- The flake lives in `~/nixos/` rather than `/etc/nixos/` to make customization
  feel like editing dotfiles rather than system administration.

## Consequences

- Users can customize their system by editing `~/nixos/flake.nix` and the
  modules it imports, using standard NixOS option overrides.
- The distribution must maintain a stable module interface — breaking changes
  to option names require a deprecation path.
- A binary cache must be hosted before public release so users do not compile
  from source on first install.
- The ISO build pipeline must be maintained as part of the release process.
