{
  inputs = {
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";
  };

  outputs = {
    self,
    nixpkgs,
  }: {
    lib = import ./lib.nix {
      inherit (nixpkgs-lib) lib;
      stateVersion = "23.11";
      # Extra info for version check message
      revInfo =
        if nixpkgs-lib ? rev
        then " (nixpkgs-lib.rev: ${nixpkgs-lib.rev})"
        else "";
    };
    nixosModules.nixos23_11 = {config}: {
      options = {};
      config = {};
    };
    nixosModules.default = self.nixosModules.nixos23_11;
    overlays."unstable" = final: prev: {};
    overlays."unfree" = final: prev: {};
    overlays.stable = final: prev: {};
  };
}
