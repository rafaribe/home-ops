{pkgs, ...}: let
  nfsMounts = [
    {
      mountPoint = "/mnt/storage-0/docs";
      serverPath = "truenas.rafaribe.com:/mnt/storage-0/docs";
    }
    {
      mountPoint = "/mnt/storage-0/config";
      serverPath = "truenas.rafaribe.com:/mnt/storage-0/config";
    }
    {
      mountPoint = "/mnt/storage-0/minio";
      serverPath = "truenas.rafaribe.com:/mnt/storage-0/minio";
    }
    {
      mountPoint = "/mnt/storage-0/syncthing";
      serverPath = "truenas.rafaribe.com:/mnt/storage-0/syncthing";
    }
    {
      mountPoint = "/mnt/storage-0/photos";
      serverPath = "truenas.rafaribe.com:/mnt/storage-0/photos";
    }
    {
      mountPoint = "/mnt/storage-0/pc-backups";
      serverPath = "truenas.rafaribe.com:/mnt/storage-0/pc-backups";
    }
  ];
in {
  fileSystems = builtins.listToAttrs (map (mount: {
      name = mount.mountPoint;
      value = {
        device = mount.serverPath;
        fsType = "nfs";
      };
    })
    nfsMounts);
}
