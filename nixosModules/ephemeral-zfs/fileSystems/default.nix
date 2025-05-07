{ config
, lib
, ...
}:
let
  cfg = config.zfs-root.fileSystems;
  inherit (lib) mkIf types mkDefault mkOption mkMerge mapAttrsToList;
in
{
  options.zfs-root.fileSystems = {
    datasets = mkOption {
      description = "Set mountpoint for datasets";
      type = types.attrsOf types.str;
      default = { };
    };
    bindmounts = mkOption {
      description = "Set mountpoint for bindmounts";
      type = types.attrsOf types.str;
      default = { };
    };
    efiSystemPartitions = mkOption {
      description = "Set mountpoint for efi system partitions";
      type = types.listOf types.str;
      default = [ ];
    };
    swapPartitions = mkOption {
      description = "Set swap partitions";
      type = types.listOf types.str;
      default = [ ];
    };
  };

  /*
     The lines from here until
    cf.efiSystemPartitions are the configurations
    set above: datasets, bindmounts, efiSystemPartitions
  */

  config.fileSystems = mkMerge (
    mapAttrsToList
      (dataset: mountpoint: {
        "${mountpoint}" = {
          device = "${dataset}";
          fsType = "zfs";
          options = [ "X-mount.mkdir" "noatime" ];
          neededForBoot = true;
        };
      })
      cfg.datasets
    /*
      mapAttrsToList concatenates bindsrc and mountpoint (which
      come from the next function in line
      into the attribute set that follows
    */
    ++ mapAttrsToList
      (bindsrc: mountpoint: {
        "${mountpoint}" = {
          device = "${bindsrc}";
          fsType = "none";
          options = [ "bind" "X-mount.mkdir" "noatime" ];
        };
      })
      /*
        creates a larger list of bindmounts + efi system paritions
        the result gets passed to
      */
      cfg.bindmounts
    ++ map
      (esp: {
        "/boot/efis/${esp}" = {
          device = "${config.zfs-root.boot.devNodes}${esp}";
          fsType = "vfat";
          options = [
            "x-systemd.idle-timeout=1min"
            "x-systemd.automount"
            "noauto"
            "nofail"
            "noatime"
            "X-mount.mkdir"
          ];
        };
      })
      cfg.efiSystemPartitions
    /**/
  );

  /*
     Question, why does the above c3 conigs needs
    the config.*filesSystems*.<name> but this one
    only needs config.swapDevices
  */
  config.swapDevices = mkDefault (map
    (swap: {
      device = "${config.zfs-root.boot.devNodes}${swap}";
      discardPolicy = mkDefault "both";
      randomEncryption = {
        enable = true;
        allowDiscards = mkDefault true;
      };
    })
    cfg.swapPartitions);
}
