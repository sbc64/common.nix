{pkgs, ...}: {
  #imports = ["${pkgs-darwin}/nixos/modules/virtualisation/qemu-vm.nix"];
  # The tmpfs fileSystem idea is copied from the above quemu-vm module.
  # The qemu-vm module only works on nixos system and does not work on
  # darwin, which is why for darwin I just use the filesystems instead
  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
  };
  documentation.nixos.enable = false;
  boot.loader.grub.device = "/dev/disk/by-label/nixos";
  networking = {
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
  };
  services.getty.autologinUser = "root";
  security.sudo.wheelNeedsPassword = false;
  # TODO figure out how to open ports to allow ssh access
  virtualisation.vmVariant = {
    virtualisation = {
      graphics = false;
    };
  };
}
