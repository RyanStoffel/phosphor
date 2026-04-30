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

  environment.systemPackages = with pkgs; [
    git
    vim
    gptfdisk
    parted
    (writeShellScriptBin "phosphor-install" ''
      exec ${pkgs.bash}/bin/bash /etc/phosphor-install/installer.sh "$@"
    '')
  ];

  environment.etc."phosphor-install/installer.sh".source = ./installer.sh;
  environment.etc."phosphor-install/phosphor".source = ../.;

  environment.etc."phosphor-install/flake.nix".text = ''
    {
      description = "My Phosphor configuration";

      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        home-manager = {
          url = "github:nix-community/home-manager";
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
              phosphor.username = "__USERNAME__";
              phosphor.hostname = "phosphor";
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ phosphor.homeManagerModules.default ];
              home-manager.users.__USERNAME__ = { ... }: {
                home.stateVersion = "25.05";
                home.username = "__USERNAME__";
                home.homeDirectory = "/home/__USERNAME__";
              };
            }
          ];
        };
      };
    }
  '';
}
