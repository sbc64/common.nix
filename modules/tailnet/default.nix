{
  config,
  lib,
  pkgs,
  callingFlakePath,
  ...
}: let
  cfg = config.tailnet;
  inherit (lib) mkIf types mkOption mkEnableOption;
in {
  options.tailnet = {
    enable = mkOption {
      type = types.bool;
      default = true;
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
      enable = true;
      extraUpFlags = [
        "${lib.optionalString cfg.allowSSH "--ssh"}"
      ];
      authKeyFile = config.age.secrets.tsAuthKey.path;
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
