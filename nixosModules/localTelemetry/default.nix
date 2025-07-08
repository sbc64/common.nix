{ config
, lib
, ...
}:
let
  cfg = config.localTelemetry;
  inherit (lib) mkIf types mkOption;
in
{
  options.localTelemetry = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };
  imports = [
    ../nodeExporter
  ];
  config = mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      listenAddress = "127.0.0.1";
      globalConfig.scrape_interval = "10s"; # "1m"
      exporters.node = {
        #extraFlags = [ "--collector.ethtool" "--collector.softirqs" "--collector.tcpstat" "--collector.wifi" ];
      };
      exporters.zfs.enable = true;
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{
            targets = [ "localhost:${builtins.toString config.services.prometheus.exporters.node.port}" ];
          }];
        }
      ];
    };
    services.grafana = {
      enable = true;
      settings = {
        auth.disable_login = true;
      };
      provision.datasources.settings = {
        apiVersion = 1;
        datasources = [{
          name = "Prometheus";
          type = "prometheus";
          url = "http://localhost:${builtins.toString config.services.prometheus.port}";
        }];
      };
    };
  };
}


