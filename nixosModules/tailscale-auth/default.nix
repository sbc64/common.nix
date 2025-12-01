{ callingFlakePath
, ...
}: {
  age.secrets."tsAuthKey" = {
    file = "${callingFlakePath}/secrets/tailscale-auth.age";
    path = "/run/tsAuthKey";
    symlink = false;
  };
}
