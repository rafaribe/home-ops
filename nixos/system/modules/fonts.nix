{pkgs, ...}: {
  fonts.packages = with pkgs; [
    font-awesome # installed for waybar icons
    jetbrains-mono # terminal
    # iosevka-bin
    (nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
  ];
}
