{
  config,
  lib,
  ...
}: let
  cfg = config.nodeExporter;
  inherit (lib) mkIf types mkMerge mkOption mkDefault;
in {
  options.nodeExporter = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
    port = mkOption {
      type = types.int;
      default = 9132;
    };
  };
  config = mkIf (cfg.enable) {
    services.prometheus = {
      exporters = {
        node = {
          enable = true;
          enabledCollectors = ["systemd"];
          port = cfg.port;
          listenAddress = "127.0.0.1";
        };
      };
    };
  };
}
