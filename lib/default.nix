# https://github.com/otavio/nix-config/blob/acd39f39b97677e1bd7aadf542fc41c334b1890d/lib/default.nix#L4-L13
lib: libModules: callingFlakePath: rec {
  mkSecret = name: { secretDir
                   , dir ? "/run/agenix"
                   , path ? "${dir}/${name}"
                   , symlink ? true
                   , mode ? "0400"
                   , group ? "0"
                   , owner ? "0"
                   ,
                   }: {
    file = "${secretDir}/${name}.age";
    inherit name path symlink mode group owner;
  };

  mkSecrets = secrets:
    builtins.mapAttrs
      (
        name: value:
          mkSecret name value
      )
      secrets;

  mkHost =
    { hostname
    , stateVersion
    , inputs ? { }
    , system ? "x86_64-linux"
    , extraModules ? [ ]
    ,
    }:
    let
      libx = inputs.libx.lib callingFlakePath;
    in
    lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs libModules callingFlakePath libx;
      };
      nixpkgs.hostPlatform = system;
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
            else { }
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
            else { }
          )
          libModules.minimal
          libModules.nix
          libModules.tmux
          libModules.agenix
        ]
        ++ extraModules;
    };

  mkHosts = configs:
    builtins.mapAttrs
      (
        name: value:
          mkHost ({ hostname = name; } // value)
      )
      configs;
}
