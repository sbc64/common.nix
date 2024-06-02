{pkgs, ...}: {
  boot.loader.systemd-boot.configurationLimit = 25;
  nix = {
    package = pkgs.nixVersions.stable;
    settings = {
      trusted-users = ["root" "@admin" "@wheel"];
      substituters = [
        "https://devenv.cachix.org"
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://nixos-dash-docset.cachix.org"
        "https://colmena.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nixos-dash-docset.cachix.org-1:CTP+Rqm1pnWU0lFaCdnN3wZmGkVnB/xoTV/SQ4T1gAU="
        "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
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
