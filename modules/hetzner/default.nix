{
  modulesPath,
  lib,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  boot.loader.grub = {
    efiSupport = lib.mkDefault true;
    efiInstallAsRemovable = lib.mkDefault true;
  };
}
