lib: libModules: callingFlakePath: rec {
  mkHost = {
    hostname,
    stateVersion,
    inputs ? {},
    system ? "x86_64-linux",
    extraModules ? [],
  }:
    lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs callingFlakePath;
      };
      modules =
        [
          {
            networking.hostName = lib.mkDefault hostname;
            networking.hostId = lib.mkDefault (builtins.substring 0 8 (
              builtins.hashString "md5" hostname
            ));
            system.stateVersion = lib.mkDefault stateVersion;
          }
          # TODO, replace this search files by using the way that cachix
          # searches for files
          (
            if
              (builtins.pathExists
                "${callingFlakePath}/hosts/${hostname}/default.nix")
            then "${callingFlakePath}/hosts/${hostname}"
            else {}
          )
          (
            if
              (builtins.pathExists
                "${callingFlakePath}/hosts/${hostname}/disk-config.nix")
            then {
              imports = [
                libModules.zfs-common
                libModules.disko
                "${callingFlakePath}/hosts/${hostname}/disk-config.nix"
              ];
              disko-zfs.enable = lib.mkDefault true;
            }
            else {}
          )
          # TODO, auto expand list of modules using self.nixosModules
          libModules.common
          libModules.agenix
        ]
        ++ extraModules;
    };

  mergeIfNotExist = set1: set2: let
    filteredSet2 = lib.filterAttrs (name: value: !builtins.hasAttr name set1) set2;
  in
    set1 // filteredSet2;
  mkHosts = hosts:
    builtins.mapAttrs (
      name: value:
        mkHost (mergeIfNotExist value {hostname = name;})
    )
    hosts;
  mkColmena = {
    description ? "",
    configurations,
    nixpkgs,
    deployments,
  }: let
    inherit (builtins) mapAttrs elemAt filter;
  in
    {
      meta = {
        inherit description nixpkgs;
        nodeNixpkgs = mapAttrs (name: value: value.pkgs) configurations;
        nodeSpecialArgs = mapAttrs (name: value: value._module.specialArgs) configurations;
      };
    }
    // mapAttrs (name: value: {
      imports =
        value._module.args.modules
        ++ [
          {
            deployment = elemAt (filter (v: v.targetHost == name) deployments) 0;
          }
        ];
    })
    configurations;
}
