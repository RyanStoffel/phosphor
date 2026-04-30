#!/usr/bin/env bash

set -eu

say() {
  printf '\n==> %s\n' "$1"
}

fail() {
  printf '\nError: %s\n' "$1" >&2
  exit 1
}

prompt() {
  printf '%s' "$1" > /dev/tty
}

prompt_password() {
  prompt "$1"
  stty -echo < /dev/tty
  IFS= read -r password < /dev/tty
  stty echo < /dev/tty
  printf '\n' > /dev/tty
  printf '%s' "$password"
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

if ! mountpoint -q /mnt; then
  fail "/mnt is not mounted. Partition and mount the target disk before running the installer."
fi

say "Collecting installation settings"

while :; do
  prompt "Username: "
  IFS= read -r username

  if validate_username "$username"; then
    break
  fi

  printf 'Use lowercase letters, numbers, hyphens, or underscores.\n'
done

while :; do
  password="$(prompt_password "Password: ")"
  password_confirm="$(prompt_password "Confirm password: ")"

  if [ -z "$password" ]; then
    printf 'Password cannot be empty.\n'
    continue
  fi

  if [ "$password" = "$password_confirm" ]; then
    break
  fi

  printf 'Passwords did not match. Try again.\n'
done

config_dir="$HOME/nixos"
target_config_dir="/mnt/home/$username/nixos"
repo_source="/etc/phosphor-install/phosphor"
template="/etc/phosphor-install/flake.nix"

say "Preparing managed flake in $config_dir"
mkdir -p "$config_dir"
rm -rf "$config_dir/phosphor"
cp -LR "$repo_source" "$config_dir/phosphor"
sed "s/__USERNAME__/$username/g" "$template" > "$config_dir/flake.nix"

say "Generating hardware configuration"
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix "$config_dir/hardware-configuration.nix"

say "Installing NixOS with the Phosphor flake"
nixos-install --flake "$config_dir#phosphor"

say "Copying the managed flake into the installed system"
mkdir -p "/mnt/home/$username"
rm -rf "$target_config_dir"
cp -LR "$config_dir" "$target_config_dir"

say "Setting the user password"
printf '%s:%s\n' "$username" "$password" | nixos-enter --root /mnt -c 'chpasswd'
nixos-enter --root /mnt -c "chown -R $username:users /home/$username/nixos"

say "Installation complete"
printf 'Reboot when ready. After first boot, use phosphor-update to apply future updates.\n'
