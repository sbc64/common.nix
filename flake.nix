{
  description = "Common NixOS modules for my nix use cases";
  inputs = {
    # Commented out dir=lib because we need the extended lib for using functions such as
    # nixosSystem: https://github.com/NixOS/nixpkgs/blob/b878cb4ca34d62b19b06b00518d7cf249530c343/flake.nix#L18
    # Leaving this URL to think about reducing the amount of nixpkgs
    # and try to make a lean lib usage here
    #nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable";
    # This current implementation likely leaves too many copies of nixpkgs everywhere
    stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "stable";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "stable";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "stable";
    };
  };

  outputs = {
    self,
    stable,
    ...
  } @ inputs: let
    libx = import ./lib stable.lib self.nixosModules;
    stateVersion = "23.11";
  in {
    # TODO extend the standard library to include your personal functions, that
    # way you only use the extended library in all your other repos
    lib = libx;
    nixosModules = with stable.lib; let
      folder = ./modules;
      toImport = name: (import "${folder}/${name}");
      filterModules = _: value: value == "directory";
      names = builtins.attrNames (filterAttrs filterModules (builtins.readDir folder));
      modules = genAttrs names toImport;
    in
      /*
      nixosModules.default.all = mkMerge [
      ];
      */
      modules
      // {
        agenix = inputs.agenix.nixosModules.default;
        disko = inputs.disko.nixosModules.disko;
        pi4Base = {lib, ...}: {
          imports = [
            "${stable}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            "${stable}/nixos/modules/installer/cd-dvd/channel.nix"
          ];
          networking = {
            wireless = {
              enable = true;
              networks."Atila".psk = "???????????";
            };
            hostId = "8d0986db"; #worthy-elk
          };
          system.activationScripts.installConfiguration = ''
             if [ ! -f /etc/nixos/configuration.nix ]; then
                 mkdir -p /etc/nixos
            fi
          '';

          sdImage.firmwareSize = 5000;
          fileSystems = {
            "/boot/firmware" = {
              device = "/dev/disk/by-label/FIRMWARE";
              fsType = "vfat";
              options = ["nofail" "noauto"];
            };
            "/" = {
              device = "/dev/disk/by-label/NIXOS_SD";
              fsType = "ext4";
            };
          };
        };
      };

    nixosConfigurations = (libx self.outPath).mkHosts {
      pi4Base = {
        inherit stateVersion;
        system = "aarch64-linux";
        hostname = "nixos";
        extraModules = with self.nixosModules; [
          pi4Base
          ({lib, ...}: {
            # This follows the dvd boot installer
            boot.loader.grub.enable = lib.mkForce false;
          })
        ];
      };
      vm = {
        system = "aarch64-linux";
        inherit stateVersion;
        extraModules = [
          self.nixosModules.vm
          {
            virtualisation.vmVariant.virtualisation.host.pkgs = stable.legacyPackages.aarch64-darwin;
          }
        ];
      };
    };
    packages = {
      aarch64-darwin.vm = self.nixosConfigurations.vm.config.system.build.vm;
      aarch64-linux.pi4SDBase = self.nixosConfigurations.pi4Base.config.system.build.sdImage;
    };
    apps.aarch64-darwin.default = {
      type = "app";
      program = "${
        stable.legacyPackages.aarch64-darwin.writeShellScript "run-vm.sh" ''
          export NIX_DISK_IMAGE=$(mktemp -u -t vm.qcow2)
          echo "IMAGE PATH $NIX_DISK_IMAGE"
          trap "rm -f $NIX_DISK_IMAGE" EXIT
          ${self.packages.aarch64-darwin.vm}/bin/run-vm-vm''
      }";
    };
  };
}
