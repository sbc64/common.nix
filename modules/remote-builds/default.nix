{
  config,
  lib,
  pkgs,
  ...
}: let
  builderKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICllOC9xAgR6ROJSFotRNrfErKGayL+lVd0fjC3g3VtG";
in {
  users.users."builder" = {
    isSystemUser = true;
    group = "@builder";
    openssh.authorizedKeys = [
      builderKey
    ];
  };
  nix = {
    settings.trusted-users = ["@builder"];
    sshServe = {
      enable = true;
      protocol = "ssh-ng";
      nix.sshServe.keys = [
        builderKey
      ];
    };
  };
}
