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
  config = mkMerge [
    (mkIf (cfg.enable) {
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
    })
    (mkIf (config.tailnet.enable) {
      services.prometheus.exporters.node = {
        listenAddress = lib.mkForce "0.0.0.0";
      };
      networking.firewall = {
        filterForward = mkDefault true;
        extraInputRules = ''
          iifname tailscale0 tcp dport ${builtins.toString cfg.port} accept
          tcp dport ${builtins.toString cfg.port} drop
        '';
      };
    })
  ];
}
