# you only need this package when you have a UI
{ pkgs, ... }: {
  fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "DroidSansMono"
      ];
    })
    fira-code
    fira
    fira-code-symbols
    cooper-hewitt
    ibm-plex
    jetbrains-mono
    iosevka
    spleen
    powerline-fonts
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
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ];
}
