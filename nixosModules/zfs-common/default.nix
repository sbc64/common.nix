{ config
, lib
, libModules
, ...
}:
let
  cfg = config.disko-zfs;
  inherit (lib) mkIf mkDefault mkEnableOption;
in
{
  options.disko-zfs.enable = mkEnableOption "enable zfs with disko";
  imports = [
    libModules.srvos.mixins-latest-zfs-kernel
  ];
  config = mkIf cfg.enable {
    boot = {
      supportedFilesystems = [ "zfs" ];
      initrd.supportedFilesystems = [ "zfs" ];
      zfs = {
        # needed because /dev/disk/by-id is empty in qemu-vms
        #zfs.devNodes = "/dev/disk/by-uuid";
        forceImportRoot = mkDefault false;
      };
      loader = {
        systemd-boot = {
          enable = lib.mkDefault true;
          consoleMode = "max";
        };
        timeout = 5;
        efi.canTouchEfiVariables = lib.mkDefault false; # Set to true on install
        generationsDir.copyKernels = true;
      };
    };
  };
}
