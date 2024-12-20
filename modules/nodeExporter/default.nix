{ config
, lib
, ...
}:
let
  cfg = config.nodeExporter;
  inherit (lib) mkIf types mkMerge mkOption mkDefault;
in
{
  options.nodeExporter = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
    port = mkOption {
      type = types.int;
      default = 9132;
    };
    agent = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      remoteWriteUrl = mkOption {
        type = types.str;
        default = null;
      };
    };
  };
  config = mkMerge [
    (mkIf (cfg.enable) {
      services.prometheus = {
        exporters = {
          node = {
            enable = true;
            enabledCollectors = [ "systemd" ];
            port = cfg.port;
            listenAddress = "127.0.0.1";
          };
        };
      };
    })
    (
      mkIf cfg.agent.enable {
        services.prometheus = {
          enable = true;
          enableAgentMode = true;
          remoteWrite = [
            {
              url = "${cfg.agent.remoteWriteUrl}/api/v1/write";
            }
          ];
        };
      }
    )
  ];
}
