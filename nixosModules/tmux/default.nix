{ config, lib, ... }: {
  programs.tmux = {
    enable = lib.mkDefault true;
    newSession = true;
    extraConfig = builtins.readFile ./tmux.conf;
  };
  #xdg.configFile."tmux/tmux.conf" = {
  #  source = config.lib.file.mkOutOfStoreSymlink "/home/sebas/dots/home.nix/home-manager/tui/tmux/tmux.conf";
  #};
}
