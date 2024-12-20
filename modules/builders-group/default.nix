{ config
, lib
, pkgs
, ...
}:
let

  cfg = config.ts-sso;
  inherit (lib) mkOption types mkIf;
in
{
  options.builder.group = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    user = {
      type = types.notNull or types.list;
    };
  };
  config = mkIf (cfg.enable) {
    users.extragroups.builders.members = [ cfg.user ];
  };
}
