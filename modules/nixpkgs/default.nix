{
  config,
  lib,
  pkgs,
  ...
}: {
  boot.loader.systemd-boot.configurationLimit = 50;
  nix = {
    package = pkgs.nixUnstable;
    settings = {
      trusted-users = ["root" "@admin" "@builder"];
      substituters = [
        "https://devenv.cachix.org"
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://nixos-dash-docset.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nixos-dash-docset.cachix.org-1:CTP+Rqm1pnWU0lFaCdnN3wZmGkVnB/xoTV/SQ4T1gAU="
      ];
      experimental-features = ["nix-command" "flakes"];
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
    # If set to true it will delete system profiles from the boot
    gc.automatic = false;
  };
}
