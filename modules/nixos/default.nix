{ inputs, ... }:
{
  imports = [
    inputs.stylix.nixosModules.stylix
    inputs.niri.nixosModules.niri
    ./core.nix
    ./desktop.nix
    ./packages.nix
    ./gaming.nix
  ];
}
