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
            networking.hostName = lib.mkForce hostname;
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
          libModules.common
          libModules.agenix
        ]
        ++ extraModules;
    };

  mkHosts = configs:
    builtins.mapAttrs (
      name: value:
        mkHost ({hostname = name;} // value)
    )
    configs;

  mkColmena = {
    description ? "",
    configurations,
    nixpkgs,
    deployments,
  }: let
    inherit (builtins) mapAttrs head filter;
    filterHost = name: value: value.targetHost == name;
    crtDeploymentAttr = name: head (filter (v: v.targetHost == name) deployments);
    mvIp = deploy: builtins.removeAttrs (deploy // {targetHost = deploy.ip;}) ["ip"];
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
            deployment = {buildOnTarget = true;} // mvIp (crtDeploymentAttr name);
          }
        ];
    })
    configurations;
}
