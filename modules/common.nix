{pkgs, ...}: let
  sshKeys = (import ./vars.nix).sshKeys;
  #sshPort = 45666;
  sshPort = 22;
in {
  networking.useDHCP = true;
  networking.networkmanager.enable = false;

  users.users.root = {
    initialHashedPassword = "$y$j9T$3YEmKQGneWxEvwnkfNVqx1$IWrh4Yx8e.tl04wc/q0Ht1Xkj2kKiAoy41tcECuRsc.";
    openssh.authorizedKeys.keys = sshKeys;
  };
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  services = {
    /*
    TODO remove this since all you need is wireguard ssh access
    */
    fail2ban.enable = false;
    endlessh-go = {
      enable = false;
      openFirewall = true;
      port = 22;
      extraOptions = [
        "-geoip_supplier=ip-api"
      ];
      prometheus = {
        enable = true;
        listenAddress = "127.0.0.1";
      };
    };
    openssh = {
      openFirewall = true;
      ports = [
        sshPort
      ];

      enable = true;
      settings = {
        PasswordAuthentication = false;
        LogLevel = "VERBOSE"; # neded by fail2ban
        KbdInteractiveAuthentication = false;
        AuthenticationMethods = "publickey";
        X11Forwarding = false;
        AllowTcpForwarding = true;
        AllowAgentForwarding = false;
        AllowStreamLocalForwarding = false;
      };
      allowSFTP = false;
    };
  };
  nix = {
    settings = {
      substituters = [
        "https://devenv.cachix.org"
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
      trusted-users = ["root"];
      experimental-features = ["nix-command" "flakes"];
    };
  };
  security = {
    doas.enable = true;
    sudo.enable = false;
  };
  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      jq
      htop
      busybox
      wget
      ;
  };
  programs = {
    git.enable = true;
    mosh.enable = true;
    tmux = {
      enable = true;
      newSession = true;
      extraConfig = builtins.readFile ../tmux.conf;
    };
  };
}
