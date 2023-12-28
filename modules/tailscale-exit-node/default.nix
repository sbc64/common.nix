{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.tailscale;
  isNetworkd = config.networking.useNetworkd;
  authKey = "tskey-auth-kjt4m73cntrl-fg2dknbw86yibbvbh9z66yt289wlcfyay";
in {
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    extraUpFlags = [
      "--advertise-exit-node"
    ];
  };
  systemd.services.tailscaled-autoconnect = {
    after = ["tailscale.service"];
    wants = ["tailscale.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      status=$(${config.systemd.package}/bin/systemctl show -P StatusText tailscaled.service)
      if [[ $status != Connected* ]]; then
        ${cfg.package}/bin/tailscale up --auth-key ${authKey} ${escapeShellArgs cfg.extraUpFlags}
      fi
    '';
  };
}
