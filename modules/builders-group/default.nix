{ config
, lib
, ...
}:
let
  cfg = config.builders-group;
  inherit (lib) mkOption types mkIf;
in
{
  options.builders-group = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    include = mkOption {
      type = types.listOf types.str;
      default = [ "@wheel" "root" ]; #sudo users
    };
  };
  config = mkIf (cfg.enable) {
    users.extraGroups.builders.members = cfg.include;
    nix.settings = {
      trusted-users = [ "@builders" "root" ];
    };
  };
}
