wifiname: {
  config,
  lib,
  callingFlakePath,
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
    age.secrets."${wifiname}-psk" = {
      file = "${callingFlakePath}/secrets/${wifiname}-psk.age";
      path = "/run/agenix/${wifiname}-psk";
    };
    networking.wireless.enable = true;
    networking.wireless = {
      environmentFile = config.age.secrets.${wifiname} - psk.path;
      networks.${wifiname}.psk = "@PSK@";
    };
  };
}
