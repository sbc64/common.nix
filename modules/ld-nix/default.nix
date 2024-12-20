{pkgs, ...}: {
  pogram.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # packages that become available to the linker
    ];
  };
}
