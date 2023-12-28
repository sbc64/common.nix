{
  config,
  lib,
  ...
}: let
  cfg = config.disko-zfs;
  inherit (lib) mkIf mkForce mkDefault mkEnableOption;
in {
  options.disko-zfs.enable = mkEnableOption "enable zfs with disko";
  config = mkIf (cfg.enable) {
    boot = {
      kernelPackages =
        mkForce config.boot.zfs.package.latestCompatibleLinuxPackages;
      supportedFilesystems = ["zfs"];
      zfs = {
        # needed because /dev/disk/by-id is empty in qemu-vms
        #zfs.devNodes = "/dev/disk/by-uuid";
        forceImportRoot = mkDefault false;
      };
      loader = {
        generationsDir.copyKernels = true;
        grub = {
          enable = true;
          copyKernels = true;
          efiSupport = true;
          zfsSupport = true;
          efiInstallAsRemovable = mkDefault true;
        };
      };
    };
  };
}
