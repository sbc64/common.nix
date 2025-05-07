{ config
, lib
, pkgs
, ...
}:
let
  builderKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICllOC9xAgR6ROJSFotRNrfErKGayL+lVd0fjC3g3VtG";
in
{
  users.groups.builders = {
    members = [ "builder" ];
  };
  users.users."builder" = {
    isNormalUser = true;
    group = "builders";
    openssh.authorizedKeys.keys = [
      builderKey
    ];
  };
  nix = {
    settings = {
      trusted-users = [ "@builders" ];
      /*
      https://nixos.wiki/wiki/Distributed_build#Remote_builders.27_features
      Feature	Derivations requiring it
      kvm	Everything which builds inside a vm, like NixOS tests
      nixos-test	Machine can run NixOS tests
      big-parallel	kernel config, libreoffice, evolution, llvm and chromium
      benchmark	Machine can generate metrics (means the builds usually takes the same amount of time)
      */
    };
    sshServe = {
      enable = true;
      protocol = "ssh-ng";
      keys = [
        builderKey
      ];
    };
  };
}
