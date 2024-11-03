{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    wget
    tldr
    hyfetch
  ];
}
