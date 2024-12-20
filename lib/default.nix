{
  inputs,
  outputs,
  stateVersion,
  lib,
  ...
}: let
in {
  mkHome = {
    hostname,
    username,
    desktop ? null,
    platform ? "x86_64-linux",
  }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${platform};
      extraSpecialArgs = {
        inherit inputs outputs desktop hostname platform username stateVersion;
      };
      modules = [../home-manager];
    };

  mkHost = {
    hostname,
    system ? "x86_64-linux",
    inputs,
    extraModules ? [],
    pkgSet ? "nixos",
  }: let
    pkgs = inputs."${pkgSet}".legacyPackages.${system};
    lib = inputs."${pkgSet}".lib;
  in
    lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
      };
      modules =
        [
          ({config, ...}: let
          in {
            networking.hostName = lib.mkDefault hostname;
            networking.hostId = lib.mkDefault (builtins.substring 0 8 (
              builtins.hashString "md5" hostname
            ));
            system.stateVersion = lib.mkDefault stateVersion;
          })
          (
            if
              (builtins.pathExists
                ../hosts/${hostname}/default.nix)
            then ../hosts/${hostname}
            else {}
          )
          (
            if
              (builtins.pathExists
                ../hosts/${hostname}/disk-config.nix)
            then {
              imports = [
                ../hosts/${hostname}/disk-config.nix
                ../modules/zfs-common
              ];
            }
            else {}
          )
          (import ../hosts/common.nix {inherit pkgs lib;})
        ]
        ++ extraModules;
    };
  mkHost = {
    ipOrHostname,
    self,
    nixosConfiguration ? "",
    sshUser ? "root",
    sshOptsArg ? [],
    fastConnection ? false,
    remoteBuild ? true,
    magicRollback ? true,
  }: let
    config =
      if nixosConfiguration == ""
      then ipOrHostname
      else nixosConfiguration;
    cfg = self.nixosConfigurations."${config}";
    system = cfg.config.nixpkgs.system;
    sshOpts =
      [
        /*
        (if (sshOptsArg == []) then
        "-p" (builtins.toString (builtins.elemAt cfg.config.services.openssh.ports 0))
        else sshOptsArg)
        */
      ]
      ++ sshOptsArg;
  in {
    inherit fastConnection remoteBuild sshUser magicRollback sshOpts;
    hostname = ipOrHostname;
    profiles.system = {
      user = sshUser;
      path = self.inputs.deploy-rs.lib."${system}".activate.nixos cfg;
    };
  };
  ## Create deployment configuration for use with deploy-rs.
  ##
  ## ```nix
  ## mkDeploy {
  ##   inherit self;
  ##   overrides = {
  ##     my-host.system.sudo = "doas -u";
  ##   };
  ## }
  ## ```
  ##
  #@ { self: Flake, overrides: Attrs ? {} } -> Attrs
  mkDeploy2 = {
    self,
    overrides ? {},
  }: let
    hosts = self.nixosConfigurations or {};
    names = builtins.attrNames hosts;
    nodes =
      lib.foldl
      (result: name: let
        host = hosts.${name};
        user = host.config.plusultra.user.name or null;
        inherit (host.pkgs) system;
      in
        result
        // {
          ${name} =
            (overrides.${name} or {})
            // {
              hostname = overrides.${name}.hostname or "${name}";
              profiles =
                (overrides.${name}.profiles or {})
                // {
                  system =
                    (overrides.${name}.profiles.system or {})
                    // {
                      path = deploy-rs.lib.${system}.activate.nixos host;
                    }
                    // lib.optionalAttrs (user != null) {
                      user = "root";
                      sshUser = user;
                    }
                    // lib.optionalAttrs
                    (host.config.plusultra.security.doas.enable or false)
                    {
                      sudo = "doas -u";
                    };
                };
            };
        })
      {}
      names;
  in {inherit nodes;};
}
