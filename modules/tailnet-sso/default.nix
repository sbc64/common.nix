{
  config,
  lib,
  ...
}: let
  cfg = config.ts-sso;
  inherit (lib) mkOption types mkIf;
in {
  options.ts-sso = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
    group = mkOption {
      type = types.str;
      default = "tailnet";
    };
    tld = mkOption {
      type = types.str;
      default = "";
    };
    portToForward = mkOption {
      type = types.port;
      default = 80;
    };
    interface = mkOption {
      type = types.str;
      default = "eth0";
    };
  };
  config = mkIf (cfg.enable) {
    users.extraGroups.${cfg.group}.members = [
      "caddy"
      "tailscale"
      "tailscale-nginx-auth"
    ];

    services.tailscale.permitCertUid = "caddy";
    services.tailscaleAuth = {
      enable = true;
      socketPath = "/run/ts.sock";
      group = cfg.group;
    };
    # Why do these ports need to be open?
    # is it for letsencrypt to enable the domain for tailscale?
    networking.firewall.interfaces."${cfg.interface}".allowedTCPPorts = [
      80
      443
    ];
    services.caddy = {
      group = "tailnet";
      enable = true;
      # Need to change user to root or allow
      logFormat = ''
        level WARN
      '';
      virtualHosts."${config.networking.hostName}.${cfg.tld}" = {
        listenAddresses = [
          "0.0.0.0"
        ];
        extraConfig = ''
          forward_auth unix/${config.services.tailscaleAuth.socketPath} {
           uri /auth
           header_up Remote-Addr {remote_host}
           header_up Remote-Port {remote_port}
           header_up Original-URI {uri}
           copy_headers {
             Tailscale-User>X-Webauth-User
             Tailscale-Name>X-Webauth-Name
             Tailscale-Login>X-Webauth-Login
             Tailscale-Tailnet>X-Webauth-Tailnet
             Tailscale-Profile-Picture>X-Webauth-Profile-Picture
           }
          }
          reverse_proxy :${builtins.toString cfg.portToForward}
        '';
      };
    };
  };
}
