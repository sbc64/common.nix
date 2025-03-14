{ config
, pkgs
, lib
, ...
}:
let
  folder = ./caches;
  toImport = name: value: folder + ("/" + name);
  filterCaches = key: value: value == "regular" && lib.hasSuffix ".nix" key;
  imports = lib.mapAttrsToList toImport (lib.filterAttrs filterCaches (builtins.readDir folder));
in
{
  inherit imports;
  environment.systemPackages = [ pkgs.cachix ];
}
