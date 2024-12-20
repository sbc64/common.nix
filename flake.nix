{
  description = "Common NixOS modules for my nix use cases";
  inputs = {
    # Commented out dir=lib because we need the extended lib for using functions such as
    # nixosSystem: https://github.com/NixOS/nixpkgs/blob/b878cb4ca34d62b19b06b00518d7cf249530c343/flake.nix#L18
    # Leaving this URL to think about reducing the amount of nixpkgs
    # and try to make a lean lib usage here
    #nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable";
    # This current implementation likely leaves too many copies of nixpkgs everywhere
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    stable.url = "github:NixOS/nixpkgs/nixos-23.11";
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
  };

  outputs = {
    self,
    unstable,
    stable,
    ...
  } @ inputs: let
    libx = import ./lib unstable.lib self.nixosModules;
    stateVersion = "23.11";
  in {
    # TODO extend the standard library to include your personal functions, that
    # way you only use the extended library in all your other repos
    lib = libx;
    nixosModules = with unstable.lib; let
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
        pi4Base = {...}: {
          imports = [
            "${stable}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            "${stable}/nixos/modules/installer/cd-dvd/channel.nix"
            self.nixosModules.common
          ];
          networking = {
            wireless = {
              enable = true;
              networks."Atila".psk = "atilaeluno9395";
            };
          };
          system.activationScripts.installConfiguration = ''
             if [ ! -f /etc/nixos/configuration.nix ]; then
                 mkdir -p /etc/nixos
            fi
          '';
          #cp -r ${./nixos}/* /etc/nixos
          fileSystems."/" = {
            device = "/dev/disk/by-label/NIXOS_SD";
            fsType = "ext4";
          };
        };
      };

    nixosConfigurations = {
      pi4Base = (libx self.outPath).mkHost {
        inherit stateVersion;
        system = "aarch64-linux";
        hostname = "nixos";
        extraModules = [
          self.nixosModules.pi4Base
        ];
      };
      vm = (libx self.outPath).mkHost {
        hostname = "vm";
        system = "aarch64-linux";
        inherit stateVersion;
        extraModules = [
          self.nixosModules.vm
          {
            virtualisation.vmVariant.virtualisation.host.pkgs = unstable.legacyPackages.aarch64-darwin;
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
        unstable.legacyPackages.aarch64-darwin.writeShellScript "run-vm.sh" ''
          export NIX_DISK_IMAGE=$(mktemp -u -t vm.qcow2)
          echo "IMAGE PATH $NIX_DISK_IMAGE"
          trap "rm -f $NIX_DISK_IMAGE" EXIT
          ${self.packages.aarch64-darwin.vm}/bin/run-vm-vm''
      }";
    };
  };
}
