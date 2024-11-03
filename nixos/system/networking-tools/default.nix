# amaterasu is my desktop PC
{
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hardware.nix
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ../modules
  ];

  # Open ports in the firewall.
  programs.mosh.enable = true;

  networking = {
    hostName = "networking-tools";
    firewall.allowedTCPPorts = [
      80
      443
      11434 # ollama
    ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
