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
    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";

      # make sure tailscale is running before trying to connect to tailscale
      after = ["network-pre.target" "tailscale.service"];
      wants = ["network-pre.target" "tailscale.service"];
      wantedBy = ["multi-user.target"];

      # set this service as a oneshot job
      serviceConfig.Type = "oneshot";

      # have the job run this shell script
      script = with pkgs; ''
        echo "Checking if already authenticated to Tailscale ..."
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then  # do nothing
             echo "Already authenticated to Tailscale, exiting."
          exit 0
        fi

        echo "Authenticating with Tailscale ..."
        ${tailscale}/bin/tailscale up \
          --auth-key file:${config.age.secrets.tsAuthKey.path} \
          ${lib.optionalString cfg.allowSSH "--ssh"} \
          ${
          lib.optionalString (cfg.exitNode != "") "--exit-node=${cfg.exitNode} \
            --exit-node-allow-lan-access=${builtins.toString cfg.allowLanAccess}"
        }
      '';
    };
  };
}
