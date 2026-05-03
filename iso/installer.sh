#!/usr/bin/env bash

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  exec sudo -E bash "$0" "$@"
fi

log_file="/var/log/phosphor-install.log"
config_dir="/mnt/root/phosphor-installer"
repo_source="/etc/phosphor-install/phosphor"

: > "$log_file"

banner() {
  clear
  cat <<'EOF'
 ____  _                     _
|  _ \| |__   ___  ___ _ __ | |__   ___  _ __
| |_) | '_ \ / _ \/ __| '_ \| '_ \ / _ \| '__|
|  __/| | | | (_) \__ \ |_) | | | | (_) | |
|_|   |_| |_|\___/|___/ .__/|_| |_|\___/|_|
                      |_|
EOF
  printf '\n'
}

say() {
  gum style --foreground 2 --bold "$1"
}

fail() {
  gum style --foreground 1 --bold "$1" >&2
  gum style --foreground 1 "Installer log: $log_file" >&2
  exit 1
}

require_uefi() {
  [ -d /sys/firmware/efi ] || fail "Phosphor installer currently requires UEFI boot mode."
}

validate_username() {
  case "$1" in
    "" | [!a-z]* | *[!a-z0-9_-]* )
      return 1
      ;;
    * )
      return 0
      ;;
  esac
}

validate_hostname() {
  case "$1" in
    "" | [!a-z0-9]* | *[!a-z0-9-]* | *- )
      return 1
      ;;
    * )
      return 0
      ;;
  esac
}

nix_escape() {
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\$/\\$/g'
}

list_install_disks() {
  lsblk -dn -o NAME,SIZE,TYPE,MODEL | while read -r name size type model; do
    [ "$type" = "disk" ] || continue
    if [ -n "${model:-}" ]; then
      printf '/dev/%s %s %s\n' "$name" "$size" "$model"
    else
      printf '/dev/%s %s\n' "$name" "$size"
    fi
  done
}

choose_disk() {
  disks="$(list_install_disks)"
  [ -n "$disks" ] || fail "No installable disks found."
  selected="$(printf '%s\n' "$disks" | gum choose --header "Select the installation disk")"
  set -- $selected
  printf '%s' "$1"
}

prompt_required() {
  label="$1"
  placeholder="$2"
  while :; do
    gum style --foreground 2 --bold "$label"
    value="$(gum input --placeholder "$placeholder")"
    [ -n "$value" ] && {
      printf '%s' "$value"
      return
    }
    gum log --level error "This value cannot be empty."
  done
}

prompt_username() {
  while :; do
    gum style --foreground 2 --bold "Choose a username"
    value="$(gum input --placeholder "ryan")"
    if validate_username "$value"; then
      printf '%s' "$value"
      return
    fi
    gum log --level error "Use lowercase letters, numbers, hyphens, or underscores."
  done
}

prompt_hostname() {
  while :; do
    gum style --foreground 2 --bold "Choose a hostname"
    value="$(gum input --value "phosphor")"
    if validate_hostname "$value"; then
      printf '%s' "$value"
      return
    fi
    gum log --level error "Use lowercase letters, numbers, and hyphens."
  done
}

prompt_password() {
  while :; do
    gum style --foreground 2 --bold "Set a password"
    password="$(gum input --password)"
    gum style --foreground 2 --bold "Confirm the password"
    password_confirm="$(gum input --password)"
    [ -n "$password" ] || {
      gum log --level error "Password cannot be empty."
      continue
    }
    [ "$password" = "$password_confirm" ] && {
      printf '%s' "$password"
      return
    }
    gum log --level error "Passwords did not match."
  done
}

write_disko_config() {
  disk="$1"
  file="$2"

  cat > "$file" <<EOF
{
  disko.devices = {
    disk.main = {
      device = "$disk";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00";
            size = "512M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
EOF
}

write_flake() {
  username_escaped="$(nix_escape "$username")"
  full_name_escaped="$(nix_escape "$full_name")"
  hostname_escaped="$(nix_escape "$hostname")"
  theme_file_escaped="$(nix_escape "$theme_file")"

  cat > "$config_dir/flake.nix" <<EOF
{
  description = "Phosphor managed system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    phosphor.url = "path:./phosphor";
  };

  outputs = { nixpkgs, home-manager, phosphor, ... } @ inputs:
  {
    nixosConfigurations.phosphor = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        phosphor.nixosModules.default
        home-manager.nixosModules.home-manager
        ./hardware-configuration.nix
        {
          phosphor.username = "$username_escaped";
          phosphor.hostname = "$hostname_escaped";
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;
          stylix.base16Scheme = phosphor + "/$theme_file_escaped";
          users.users."$username_escaped".description = "$full_name_escaped";
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [ phosphor.homeManagerModules.default ];
          home-manager.users."$username_escaped" = { ... }: {
            home.stateVersion = "25.05";
            home.username = "$username_escaped";
            home.homeDirectory = "/home/$username_escaped";
          };
        }
      ];
    };
  };
}
EOF
}

install_with_disko() {
  disko_config="/tmp/phosphor-disko.nix"

  write_disko_config "$install_disk" "$disko_config"

  if mountpoint -q /mnt; then
    umount -R /mnt
  fi

  say "Partitioning and mounting $install_disk"
  nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount "$disko_config" 2>&1 | tee -a "$log_file"
}

prepare_flake() {
  say "Preparing managed flake"
  rm -rf "$config_dir"
  mkdir -p "$config_dir"
  cp -LR "$repo_source" "$config_dir/phosphor"
  write_flake
}

generate_hardware_config() {
  say "Generating hardware configuration"
  nixos-generate-config --root /mnt 2>&1 | tee -a "$log_file"
  cp /mnt/etc/nixos/hardware-configuration.nix "$config_dir/hardware-configuration.nix"
}

lock_flake() {
  say "Locking flake inputs"
  (
    cd "$config_dir"
    nix flake lock
  ) 2>&1 | tee -a "$log_file"
}

install_system() {
  say "Installing Phosphor"
  nixos-install --flake "$config_dir#phosphor" 2>&1 | tee -a "$log_file"
}

finalize_install() {
  target_config_dir="/mnt/home/$username/nixos"

  say "Copying managed flake"
  mkdir -p "/mnt/home/$username"
  rm -rf "$target_config_dir"
  cp -LR "$config_dir" "$target_config_dir"

  say "Setting user password"
  printf '%s:%s\n' "$username" "$password" | nixos-enter --root /mnt -c 'chpasswd' 2>&1 | tee -a "$log_file"
  nixos-enter --root /mnt -c "chown -R $username:users /home/$username/nixos" 2>&1 | tee -a "$log_file"
}

banner
require_uefi

full_name="$(prompt_required "Your full name" "Ryan Stoffel")"
username="$(prompt_username)"
hostname="$(prompt_hostname)"
password="$(prompt_password)"
theme="$(gum choose --header "Choose a theme" "phosphor-green" "phosphor-amber")"
install_disk="$(choose_disk)"

case "$theme" in
  phosphor-green)
    theme_file="themes/phosphor-green.yaml"
    ;;
  phosphor-amber)
    theme_file="themes/phosphor-amber.yaml"
    ;;
  *)
    fail "Unknown theme selected."
    ;;
esac

banner
gum style --foreground 2 --bold "Phosphor will erase the selected disk and install a new system."
printf 'Name: %s\n' "$full_name"
printf 'Username: %s\n' "$username"
printf 'Hostname: %s\n' "$hostname"
printf 'Theme: %s\n' "$theme"
printf 'Disk: %s\n\n' "$install_disk"
gum confirm "Proceed with installation?" || exit 0

install_with_disko
prepare_flake
generate_hardware_config
lock_flake
install_system
finalize_install

banner
gum style --foreground 2 --bold "Phosphor installation complete."
gum style --foreground 2 "Managed flake copied to /home/$username/nixos"
gum style --foreground 2 "Use phosphor-update after first boot for future updates."
printf '\n'
if gum confirm "Reboot now?"; then
  reboot
fi
