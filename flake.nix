{
  description = "Common NixOS modules for my nix use cases";
  inputs = {
    # Commented out dir=lib because we need the extended lib for using functions such as
    # nixosSystem: https://github.com/NixOS/nixpkgs/blob/b878cb4ca34d62b19b06b00518d7cf249530c343/flake.nix#L18
    # Leaving this URL to think about reducing the amount of nixpkgs
    # and try to make a lean lib usage here
    #nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable";
    # This current implementation likely leaves too many copies of nixpkgs everywhere
    pkgs2405.url = "github:NixOS/nixpkgs/nixos-24.05";
    unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "unstable";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "pkgs2405";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "pkgs2405";
    };
    srvos.url = "github:nix-community/srvos";
  };

  outputs =
    { self
    , pkgs2405
    , ...
    } @ inputs:
    let
      # TODO extend the standard library to include your personal functions, that
      # way you only use the extended library in all your other repos
      # one way to do it is like this:
      # https://github.com/gytis-ivaskevicius/flake-utils-plus/blob/master/flake.nix
      libx = import ./lib pkgs2405.lib self.nixosModules;
      stateVersion = "24.05";
    in
    {
      lib = libx;
      nixosModules = with pkgs2405.lib; let
        folder = ./modules;
        toImport = name: (import "${folder}/${name}");
        filterModules = _: value: value == "directory";
        names = builtins.attrNames (filterAttrs filterModules (builtins.readDir folder));
        modules = genAttrs names toImport;
      in
      modules
      // {
        tsUnstable = { ... }: {
          nixpkgs.overlays = [
            (final: prev: {
              tailscaleUnstable = inputs.unstable.legacyPackages.${prev.system}.tailscale;
            })
          ];
        };
        agenix = inputs.agenix.nixosModules.default;
        disko = inputs.disko.nixosModules.disko;
        srvos = inputs.srvos.nixosModules;
        home-manager = inputs.home-manager.nixosModules.home-manager;
        pi4Base = { lib, ... }: {
          imports = [
            "${pkgs2405}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            "${pkgs2405}/nixos/modules/installer/cd-dvd/channel.nix"
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
              virtualisation.vmVariant.virtualisation.host.pkgs = pkgs2405.legacyPackages.aarch64-darwin;
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
        pkgs2405.legacyPackages.aarch64-darwin.writeShellScript "run-vm.sh" ''
          export NIX_DISK_IMAGE=$(mktemp -u -t vm.qcow2)
          echo "IMAGE PATH $NIX_DISK_IMAGE"
          trap "rm -f $NIX_DISK_IMAGE" EXIT
          ${self.packages.aarch64-darwin.vm}/bin/run-vm-vm''
      }";
      };
    };
}
