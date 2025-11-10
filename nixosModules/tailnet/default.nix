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
      # TODO, move this to a package overlay of this repo or just grab an ovelray form nixos-stagin branch
      package = (pkgs.tailscale.overrideAttrs (_: rec {
        version = "1.90.4";
        src = pkgs.fetchFromGitHub {
          owner = "tailscale";
          repo = "tailscale";
          tag = "v${version}";
          hash = "sha256-0d6NwGH79TFqOpbu8EUw/lhk+1gF7TupVxFW18pqRmc=";
        };
        vendorHash = "sha256-rV3C2Vi48FCifGt58OdEO4+Av0HRIs8sUJVvp/gEBLw=";
      })).override {
        buildGoModule = pkgs.buildGoModule.override {
          go = pkgs.buildPackages.go_1_25.overrideAttrs (_: rec {
            version = "1.25.3";
            src = pkgs.fetchurl {
              url = "https://go.dev/dl/go${version}.src.tar.gz";
              hash = "sha256-qBpLpZPQAV4QxR4mfeP/B8eskU38oDfZUX0ClRcJd5U=";
            };
          });
        };
      };
      enable = true;
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
