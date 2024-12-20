{ pkgs, lib, ... }: {
  boot.loader.systemd-boot.configurationLimit = 25;
  nixpkgs.config = {
    allowUnfree = lib.mkDefault true;
  };
  nix = {
    package = lib.mkDefault pkgs.nixVersions.stable;
    settings = {
      extra-substituters = [
        "https://devenv.cachix.org"
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://colmena.cachix.org"
      ];
      extra-trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
      ];
      extra-experimental-features = [ "nix-command" "flakes" "repl-flake"];
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
    # If set to true it will delete system profiles from the boot
    gc.automatic = false;
  };
}
