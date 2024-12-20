{
  config,
  lib,
  pkgs,
  ...
}: let
  builderKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICllOC9xAgR6ROJSFotRNrfErKGayL+lVd0fjC3g3VtG";
in {
  users.groups.builder = {
    members = ["builder" "root"];
  };
  users.users."builder" = {
    isNormalUser = true;
    group = "builder";
    openssh.authorizedKeys.keys = [
      builderKey
    ];
  };
  nix = {
    settings = {
      trusted-users = ["@builder"];
      system-features = ["big-parallel" "kvm"];
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
