{ pkgs, lib, ... }:
{
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";

  systemd.defaultUnit = "multi-user.target";

  networking.hostName = "phosphor-installer";
  networking.networkmanager.enable = true;

  programs.niri.enable = lib.mkForce false;

  services.greetd.enable = lib.mkForce false;

  services.getty.autologinUser = lib.mkForce "nixos";

  xdg.portal.enable = lib.mkForce false;

  environment.loginShellInit = ''
    if [ ! -e /tmp/phosphor-installer-ran ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ]; then
      touch /tmp/phosphor-installer-ran
      export PHOSPHOR_INSTALLER_STARTED=1
      if ! phosphor-install; then
        printf '\nPhosphor installer exited with an error. Review /var/log/phosphor-install.log.\n'
      fi
    fi
  '';

  environment.systemPackages = with pkgs; [
    git
    vim
    gum
    gptfdisk
    parted
    e2fsprogs
    (writeShellScriptBin "phosphor-install" ''
      exec ${pkgs.bash}/bin/bash /etc/phosphor-install/installer.sh "$@"
    '')
  ];

  environment.etc."phosphor-install/installer.sh".source = ./installer.sh;
  environment.etc."phosphor-install/phosphor".source = ../.;
}
