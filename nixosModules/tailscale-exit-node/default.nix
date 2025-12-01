{ config
, lib
, ...
}:
with lib; let
  cfg = config.services.tailscale;
in
{
  imports = [
    ../tailscale-auth
  ];
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    extraUpFlags = [
      "--advertise-exit-node"
    ];
  };
  systemd.services.tailscaled-autoconnect = {
    after = [ "tailscale.service" ];
    wants = [ "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      status=$(${config.systemd.package}/bin/systemctl show -P StatusText tailscaled.service)
      if [[ $status != Connected* ]]; then
        ${cfg.package}/bin/tailscale up --auth-key ${config.age.secrets.tsAuthKey.path} ${escapeShellArgs cfg.extraUpFlags}
      fi
    '';
  };
}
