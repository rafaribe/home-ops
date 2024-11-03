{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [nh nix-search-cli alejandra nil];

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/rafaribe/code/rafaribe/nix-config";
  };
  services.envfs.enable = true;
}
