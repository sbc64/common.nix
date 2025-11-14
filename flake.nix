{
  description = "Common NixOS modules for my nix use cases";
  inputs = {
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "unstable";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "unstable";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "unstable";
    };
    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "unstable";
    };
  };

  outputs =
    { self
    , unstable
    , ...
    } @ inputs:
    let
      # TODO extend the standard library to include your personal functions, that
      # way you only use the extended library in all your other repos
      # one way to do it is like this:
      # https://github.com/gytis-ivaskevicius/flake-utils-plus/blob/master/flake.nix
      libx = import ./lib unstable.lib self.nixosModules;
      stateVersion = "25.11";
    in
    {
      lib = libx;
      nixosModules = with unstable.lib; let
        folder = ./nixosModules;
        toImport = name: (import "${folder}/${name}");
        filterModules = _: value: value == "directory";
        names = builtins.attrNames (filterAttrs filterModules (builtins.readDir folder));
        modules = genAttrs names toImport;
      in
      modules
      // {
        agenix = inputs.agenix.nixosModules.default;
        disko = inputs.disko.nixosModules.disko;
        srvos = inputs.srvos.nixosModules;
        home-manager = inputs.home-manager.nixosModules.home-manager;
        pi4Base = { lib, ... }: {
          imports = [
            "${unstable}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            "${unstable}/nixos/modules/installer/cd-dvd/channel.nix"
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
              options = [ "nofail" "noauto" ];
            };
            "/" = {
              device = "/dev/disk/by-label/NIXOS_SD";
              fsType = "ext4";
            };
          };
        };
      };
      overlays = import ./overlays;
      nixosConfigurations = (libx self.outPath).mkHosts {
        pi4Base = {
          inherit stateVersion;
          system = "aarch64-linux";
          hostname = "nixos";
          extraModules = with self.nixosModules; [
            pi4Base
            ({ lib, ... }: {
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
              virtualisation.vmVariant.virtualisation.host.pkgs = unstable.legacyPackages.aarch64-darwin;
            }
          ];
        };
        installerIso = rec {
          inherit stateVersion;
          hostname = "nixos-iso";
          extraModules = [
            ({ pkgs, modulesPath, lib, ... }: {
              networking.hostId = lib.mkForce (builtins.substring 0 8 (
                builtins.hashString "md5" hostname
              ));
              imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
            })
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
        unstable.legacyPackages.aarch64-darwin.writeShellScript "run-vm.sh" ''
          export NIX_DISK_IMAGE=$(mktemp -u -t vm.qcow2)
          echo "IMAGE PATH $NIX_DISK_IMAGE"
          trap "rm -f $NIX_DISK_IMAGE" EXIT
          ${self.packages.aarch64-darwin.vm}/bin/run-vm-vm''
      }";
      };
    };
}
