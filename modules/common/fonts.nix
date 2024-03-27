{pkgs, ...}: {
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    #nerdfonts # No need to install all of them
    (nerdfonts.override {
      fonts = [
        "JetBrainsMono"
        "FiraCode"
        "DroidSansMono"
      ];
    })
    google-fonts
    inriafonts
    liberation_ttf
    open-fonts
    open-sans
    roboto
    roboto-mono
    roboto-serif
    dejavu_fonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
  ];
}
