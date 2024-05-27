{
  pkgs,
  lib,
  ...
}: let
  sshKeys = import ../ssh-key;
in {
  imports = [
    ../nixpkgs
    ./fonts.nix
  ];
  boot = let
    modules = ["xhci_pci" "ahci" "nvme" "uas" "usbhid" "usb_storage" "sd_mod" "sdhci_pci"];
  in {
    initrd.availableKernelModules = modules;
    kernelModules = modules;
    loader.timeout = lib.mkForce 5;
  };
  networking = {
    networkmanager.enable = lib.mkDefault false;
    useDHCP = lib.mkDefault true;
    nftables.enable = lib.mkDefault true;
  };
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
    smartd.enable = lib.mkDefault true;
    openssh = {
      enable = true;
      ports = [
        22
      ];
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
      ncdu
      fd
      glances
      ;
  };
  programs = {
    git.enable = true;
    mosh.enable = true;
    tmux = {
      enable = true;
      newSession = true;
      extraConfig = builtins.readFile ./tmux.conf;
    };
  };
}
