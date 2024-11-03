{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    tailscale
  ];
}
