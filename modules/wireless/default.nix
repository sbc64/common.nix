{
  config,
  lib,
  ...
}: let
  cfg = config.within.wireless;
  inherit (lib) mkIf mkOption types;
in {
  options.within.wireless = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };
  config = mkIf (cfg.enable) {
    age.secrets."openwrt-psk" = {
      file = ../../../secrets/openwrt-psk.age;
      path = "/run/agenix/openwrt-psk";
    };
    networking.wireless.enable = true;
    networking.wireless = {
      environmentFile = config.age.secrets.openwrt-psk.path;
      networks.OpenWrt.psk = "@PSK@";
    };
  };
}
