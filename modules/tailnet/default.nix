{
  config,
  lib,
  pkgs,
  callingFlakePath,
  inputs,
  ...
}: let
  cfg = config.tailnet;
  inherit (lib) mkIf types mkOption mkMerge;
in {
  options.tailnet = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
    authenticate = mkOption {
      type = types.bool;
      default = false;
    };
    allowLanAccess = mkOption {
      description = "Allow lan access";
      type = types.bool;
      default = true;
    };
    exitNode = mkOption {
      description = "Exit node ip address";
      type = types.str;
      default = "";
    };
    allowSSH = mkOption {
      description = "Allow ssh server with tailscale";
      type = types.bool;
      default = true;
    };
  };
  config = mkIf (cfg.enable) {
    services.tailscale = {
      package = pkgs.tailscaleUnstable;
      enable = true;
      extraUpFlags = [
        (lib.optionalString cfg.allowSSH "--ssh")
        (lib.optionalString (cfg.exitNode != "") "--exit-node=${cfg.exitNode}")
        (lib.optionalString cfg.allowLanAccess "--exit-node-allow-lan-access=true")
      ];
      authKeyFile = config.age.secrets.tsAuthKey.path;
      useRoutingFeatures = "client";
    };
    age.secrets."tsAuthKey" = {
      file = "${callingFlakePath}/secrets/tailscale-auth.age";
    };
    networking = {
      firewall.trustedInterfaces = ["tailscale0"];
      firewall.allowedUDPPorts = [config.services.tailscale.port];
    };
  };
}
