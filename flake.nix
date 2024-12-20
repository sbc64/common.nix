{
  inputs = {
    # Commented out dir=lib because we need the extended lib for using functions such as
    # nixosSystem: https://github.com/NixOS/nixpkgs/blob/b878cb4ca34d62b19b06b00518d7cf249530c343/flake.nix#L18
    # Leaving this URL to think about reducing the amount of nixpkgs
    # and try to make a lean lib usage here
    #nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable";

    # This current implementation likely leaves too many copies of nixpkgs everywhere
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    #pkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";
  };

  outputs = {
    self,
    unstable,
  } @ inputs: let
    libx = import ./lib unstable.lib;
    lib = unstable.lib;
    mkHost = (libx self.outPath inputs).mkHost;
  in {
    lib = libx;
    nixosModules = let
      folder = ./modules;
      toImport = name: (import "${folder}/${name}");
      filterModules = _: value: value == "directory";
      names = builtins.attrNames (lib.filterAttrs filterModules (builtins.readDir folder));
    in
      lib.genAttrs names toImport;
    nixosConfigurations.vm = mkHost {
      hostname = "vm";
      system = "aarch64-linux";
      stateVersion = "24.05";
      extraModules = [
        self.nixosModules.vm
        {
          virtualisation.vmVariant.virtualisation.host.pkgs = unstable.legacyPackages.aarch64-darwin;
        }
      ];
    };
    packages.aarch64-darwin.vm = self.nixosConfigurations.vm.config.system.build.vm;
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

    /*
    nixosModules.default.all = mkMerge [
    ];
    */
  };
}
