# Phosphor Installer Handoff

## Current Goal

Build a Phosphor installer ISO that boots into a guided console installer and completes a full unattended single-disk install in UTM without dropping the user into manual shell recovery.

## What Was Implemented

- Home Manager `niri` module with declarative keybinds and startup apps
- Home Manager `swayidle` module
- System `phosphor-update` and `phosphor-rollback` commands
- GitHub Actions ISO build workflow at `.github/workflows/build-iso.yml`
- ISO switched from graphical live session to minimal console boot
- Guided installer rewritten in `iso/installer.sh` using `gum`
- Installer now asks for:
  - full name
  - username
  - hostname
  - password
  - theme
  - target disk
- Installer now uses `disko` to wipe, partition, format, and mount automatically

## Files Most Relevant

- `iso/installer.sh`
- `iso/default.nix`
- `.github/workflows/build-iso.yml`
- `modules/nixos/core.nix`
- `modules/nixos/default.nix`

## Problems Found During VM Testing

1. Original live ISO launched `greetd`/`niri` and was unusable in UTM.
2. Installer password prompts were broken.
3. Live ISO was missing `e2fsprogs`.
4. Generated install flake was missing `stylix` and `niri` inputs.
5. Generated flake was not locked before `nixos-install`.
6. Installer auto-restarted after failure because it was `exec`'d from shell init, hiding the real error.
7. Generated flake lived only in the live environment, so recovery state was lost after reboot.

## Latest Fixes Added But Not Yet Retested In VM

- `environment.loginShellInit` no longer `exec`s the installer
- installer is auto-run only once per boot using `/tmp/phosphor-installer-ran`
- installer failure now drops back to shell with a log hint instead of relaunching immediately
- generated install flake now lives at `/mnt/root/phosphor-installer`, so recovery survives reboot failures

## Current Expected Installer Flow

1. Boot ISO
2. Auto-login on tty1
3. Guided `gum` installer starts automatically
4. User confirms destructive install
5. `disko` wipes selected disk and mounts `/mnt`
6. Installer writes flake into `/mnt/root/phosphor-installer`
7. Installer runs `nixos-generate-config`
8. Installer locks flake inputs
9. Installer runs `nixos-install --flake /mnt/root/phosphor-installer#phosphor`
10. Installer copies managed flake into `/mnt/home/<user>/nixos`
11. Installer sets password and offers reboot

## Likely Next Test

Rebuild the ISO from the latest source and test in UTM again. If it fails, inspect:

- `/var/log/phosphor-install.log`
- `/mnt/root/phosphor-installer/`

## Recommended Next Commands

From repo root:

```bash
git add iso/default.nix iso/installer.sh T3-HANDOFF.md
git commit -m "Harden guided ISO installer"
git push
```

Then rerun the GitHub Actions ISO build and test the new artifact in UTM.
