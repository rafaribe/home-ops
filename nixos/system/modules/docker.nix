{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    docker
    docker-slim
    docker-sbom
    docker-buildx
    docker-compose
    nerdctl
    dive
    docker-ls
    crane
  ];

  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "btrfs";
    };
  };
  users.extraGroups.docker.members = ["rafaribe"];
}
