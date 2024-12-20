{lib, ...}: {
  programs.tmux = {
    enable = lib.mkDefault true;
    newSession = true;
    extraConfig = builtins.readFile ./tmux.conf;
  };
}
