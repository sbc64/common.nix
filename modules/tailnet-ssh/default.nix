{
  config,
  lib,
  ...
}: let
  cfg = config.tailnet-ssh;
  sshPort = builtins.elemAt config.services.openssh.ports 0;
  inherit (lib) mkIf types mkOption;
in {
  options.tailnet-ssh = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };
  config = mkIf (cfg.enable) {
    networking.firewall.extraInputRules = ''
      iifname tailscale0 tcp dport ${builtins.toString sshPort} accept
    '';
    # Disable listening on port 22 on all interfaces
    services.openssh.openFirewall = !cfg.enable;
  };
}
