{ config
, lib
, pkgs
, callingFlakePath
, inputs
, ...
}:
let
  cfg = config.tailnet;
  inherit (lib) mkIf types mkOption;
in
{
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
      default = false;
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
    systemd.services.tailscaled.serviceConfig = {
      Environment = ''"FLAGS=--tun tailscale0 --verbose=1 "'';
    };
    services.tailscale = {
      enable = lib.mkDefault true;
      extraUpFlags =
        [ ]
        ++ (
          if (cfg.allowSSH)
          then [ "--ssh" ]
          else [ ]
        )
        ++ (
          if (cfg.exitNode != "")
          then [ "--exit-node=${cfg.exitNode}" ]
          else [ ]
        )
        ++ (
          if (cfg.allowLanAccess)
          then [ "--exit-node-allow-lan-access=true" ]
          else [ ]
        );
      authKeyFile = config.age.secrets.tsAuthKey.path;
      useRoutingFeatures = "client";
    };
    age.secrets."tsAuthKey" = {
      file = "${callingFlakePath}/secrets/tailscale-auth.age";
      path = "/run/tsAuthKey";
      symlink = false;
    };
    networking = {
      firewall.trustedInterfaces = [ "tailscale0" ];
      firewall.allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };
}
