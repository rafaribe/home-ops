{...}: {
  nixpkgs.config.allowUnfree = true;

  imports = [

    ./boot.nix
    ./coding.nix
    ./docker.nix
    ./fonts.nix
    ./keyboard.nix
    ./linux.nix
    ./locale.nix
    ./network.nix
    ./nfs.nix
    ./nix-path.nix
    ./packages.nix
    ./python.nix
    ./shell.nix
    ./users.nix
    ./vpn.nix
  ];

  services.dbus.enable = true;
}
