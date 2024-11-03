{
  description = "rafaribe homelab NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # declarative theme management
    catppuccin.url = "github:catppuccin/nix";

    # Run unpatched dynamic binaries on NixOS
    nix-ld = {
      type = "github";
      owner = "Mic92";
      repo = "nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    talhelper = {
      url = "github:budimanjojo/talhelper";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    # Nix User Repository: User contributed nix packages
    nur.url = "github:nix-community/NUR";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # NixVirt for qemu & libvirt
    # https://github.com/AshleyYakeley/NixVirt
    nixvirt-git = {
      url = "github:AshleyYakeley/NixVirt/v0.5.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    home-manager,
    nix-ld,
    talhelper,
    ...
  } @ inputs: let
    inherit (self) outputs;
    inherit (nixpkgs.lib) nixosSystem;
    specialArgs = {inherit inputs outputs;};
  in {
    nixosConfigurations = {
      networking-tools = nixosSystem {
        specialArgs = specialArgs;
          lix-module.nixosModules.default
          ./system/networking-tools
        ];
      };
    };
  };
}
