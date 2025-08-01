{ lib
, pkgs
, ...
}:
let
  sshKeys = import ../ssh-key;
in
{
  users.users.root = {
    # TODO hashedPasswordFile = config.age.secrets.bemeurerPassword.path;
    initialHashedPassword = lib.mkForce null;
    hashedPassword = lib.mkForce "$6$IqftJJaKOvqonuin$X5syEj/INOr1Dq2hF38l5i89zXM0xXmepdzeA/2Wf7z7vrjiMGYS/1sy8VtNnOiRvhu1T1TITLCsseVXXLH7f0";
    openssh.authorizedKeys.keys = sshKeys;
  };
  hardware = {
    cpu = {
      amd.updateMicrocode = pkgs.hostPlatform.system == "x86_64-linux";
      intel.updateMicrocode = pkgs.hostPlatform.system == "x86_64-linux";
    };
    enableRedistributableFirmware = true;
  };
  boot =
    let
      modules = [ "uhci_hcd" "xen_blkfront" "ata_piix" "xhci_pci" "ahci" "nvme" "uas" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
    in
    {
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
      enable = lib.mkDefault true;
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
      btop
      busybox
      wget
      ncdu
      fd
      glances
      iperf3
      dnsutils
      fastfetch
      ;
  };
  programs = {
    git.enable = true;
    mosh.enable = true;
  };
}
