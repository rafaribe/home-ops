{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    neovim
    git
    gcc
  ];

  programs.java.enable = true;
}
