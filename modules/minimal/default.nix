{
  lib,
  pkgs,
  ...
}: let
  sshKeys = import ../ssh-key;
in {
  users.users.root = {
    # TODO hashedPasswordFile = config.age.secrets.bemeurerPassword.path;
    #initialHashedPassword = "$y$j9T$B6t8OsusxnuUA6rZVUtp11$VloSf3w9NcebBTq4ZNsug8fGTzsTgSgW/qDJgMb6AN2";
    hashedPassword = "$y$j9T$I/X.RtYltur4QwBNUOY800$4PTLxrXrQcbsar2vtigMzfAEP6/B0CRm.i3RtZNgIT3";
    openssh.authorizedKeys.keys = sshKeys;
  };
  hardware.cpu.amd.updateMicrocode = pkgs.hostPlatform.system == "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = pkgs.hostPlatform.system == "x86_64-linux      ";

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
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

  services = {
    smartd.enable = lib.mkDefault false; # Create a backups module
    scrutiny.enable = lib.mkDefault false; # Move to a backups module
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
  };
}
