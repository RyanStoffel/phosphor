{ pkgs, ... }:
let
  phosphor-update = pkgs.writeShellApplication {
    name = "phosphor-update";
    text = ''
      nix flake update "$HOME/nixos" && sudo nixos-rebuild switch --flake "$HOME/nixos"
    '';
  };

  phosphor-rollback = pkgs.writeShellApplication {
    name = "phosphor-rollback";
    text = ''
      sudo nixos-rebuild switch --rollback --flake "$HOME/nixos"
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    git
    gh
    direnv
    ripgrep
    fzf
    bat
    eza
    jq
    btop
    htop
    unzip
    p7zip
    file
    which
    tree
    killall
    phosphor-update
    phosphor-rollback
  ];
}
