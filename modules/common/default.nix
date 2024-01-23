{
  pkgs,
  lib,
  ...
}: let
  sshKeys = import ../ssh-key;
  sshPort = 22;
in {
  imports = [
    ../nixpkgs
  ];
  boot = let
    modules = ["xhci_pci" "xhci" "hcd" "ahci" "nvme" "uas" "usbhid" "usb_storage" "sd_mod" "sdhci_pci"];
  in {
    initrd.availableKernelModules = modules;
    kernelModules = modules;
  };
  networking.useDHCP = lib.mkDefault true;
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
    openssh = {
      enable = true;
      openFirewall = true;
      ports = [
        sshPort
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
