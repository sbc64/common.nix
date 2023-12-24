{
  inputs = {
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";
  };

  outputs = {
    self,
    nixpkgs-lib,
  }: {
    /*
    lib = import ./lib {
      inherit (nixpkgs-lib) lib;
      stateVersion = "23.11";
      # Extra info for version check message
      revInfo =
        if nixpkgs-lib ? rev
        then " (nixpkgs-lib.rev: ${nixpkgs-lib.rev})"
        else "";
    };
    */
    # TODO right now this is being imported as function.
    # It would be nice if it could be imported as attribute set and that
    # the default values from the line above can be deduced with `or`
    lib = import ./lib;
    nixosModules.nixos23_11 = { 
      common = import ./modules/common.nix;
      cachix = import ./modules/cachix;
    };
    /*
    nixosModules.default.all = mkMerge [
    ];
    */
    nixosModules.default = self.nixosModules.nixos23_11;
    overlays."unstable" = final: prev: {};
    overlays."unfree" = final: prev: {};
    overlays.stable = final: prev: {};
  };
}
