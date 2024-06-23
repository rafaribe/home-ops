---
hide:
  - toc
---
# Hardware

My homelab consists of a variety of hardware equipment between networking and computing power that powers all the applications needed to be run inside it:

| Device               | OS Disk Size              | Data Disk Size                       | Ram  | Operating System                                                  | Name                                                                                                | Purpose                                               | DHCP-Assign IP Address |
| -------------------- | ------------------------- | ------------------------------------ | ---- | ----------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- | ----------------------------------------------------- | ---------------------- |
| Raspberry Pi 4       | 64GB microSD              | 1TB HDD USB & 6TB WD Elements        | 4GB  | <img width="32" src="https://simpleicons.org/icons/ubuntu.svg">   | [backup-server](https://www.raspberrypi.com/tutorials/nas-box-raspberry-pi-tutorial/)               | NGINX Reverse Proxy, NFS Storage, Syncthing, Mini-NAS | 10.0.1.11              |
| Raspberry Pi 4       | 64GB microSD              | N/A                                  | 4GB  | <img width="32" src="https://simpleicons.org/icons/ubuntu.svg">   | [octoprint](https://octoprint.org/)                                                                 | Decomissioned ATM                                     | -                      |
| Asus N550J i7-4700HQ | Samsung SSD 750 Evo 250gb | 1TB Hitachi SATA HDD                 | 16GB | <img width="32" src="https://simpleicons.org/icons/proxmox.svg">  | [odin](https://www.britannica.com/topic/Odin-Norse-deity)                                           | Proxmox / VM's with Kubernetes                        | 10.0.1.7               |
| Dell Optiplex 3040   | 250GB SSD Apacer AS350    | Sandisk 250GB NVMe & 8TB WD Elements | 16GB | <img width="32" src="https://simpleicons.org/icons/proxmox.svg">  | [loki](https://www.britannica.com/topic/Loki)                                                       | Proxmox / VM's with Kubernetes                        | 10.0.1.8               |
| Odroid H2+           | 128GB Gigabyte NVME       | 4 TB WD MyPassport                   | 16GB | <img width="32" src="https://simpleicons.org/icons/proxmox.svg">  | [freya](https://www.britannica.com/topic/Frigg-Norse-mythology)                                     | Proxmox / VM's with Kubernetes                        | 10.0.1.9               |
| Dell Optiplex 3040   | 250GB SSD Apacer AS350    | Sandisk 1TB NVMe                     | 16GB | <img width="32" src="https://simpleicons.org/icons/proxmox.svg">  | [thor](https://www.britannica.com/topic/Thor-Germanic-deity)                                        | Proxmox / VM's with Kubernetes                        | 10.0.1.10              |
| TrueNas Scale Box    | Samsung 850 250GB SSD     | 6 TB WD Red Plus x2 ZFS Pool         | 32GB | <img width="32" src="https://simpleicons.org/icons/truenas.svg">  | [truenas](https://www.truenas.com/truenas-scale/)                                                   | NAS / truenas Kubernetes Cluster / Mass Storage    | truenas.rafaribe.com               |
| USG 3P               | N/A                       | N/A                                  | 4GB  | <img width="32" src="https://simpleicons.org/icons/ubiquiti.svg"> | [USG - Office](https://dl.ubnt.com/datasheets/unifi/UniFi_Security_Gateway_DS.pdf)                                | Router                                                | 10.0.1.1               |
| Unifi AP 6 Lite      | N/A                       | N/A                                  | N/A  | <img width="32" src="https://simpleicons.org/icons/ubiquiti.svg"> | [AP - Office](https://eu.store.ui.com/products/unifi-ap-6-l ite)                                     | Access Point for my Home office                       | -                      |
| Unifi AP AC-LR       | N/A                       | N/A                                  | N/A  | <img width="32" src="https://simpleicons.org/icons/ubiquiti.svg"> | [AP - Living Room](https://eu.store.ui.com/collections/unifi-network-wireless/products/unifi-ac-lr) | Access Point for my Living Room                       | -                      |
| Unifi AP 6 Lite      | N/A                       | N/A                                  | N/A  | <img width="32" src="https://simpleicons.org/icons/ubiquiti.svg"> | [AP - Garage](https://eu.store.ui.com/collections/unifi-network-wireless/products/unifi-ac-lite)    | Access Point for my Garage IoT Devices Office         | -                      |
| Unifi AP 6 Lite      | N/A                       | N/A                                  | N/A  | <img width="32" src="https://simpleicons.org/icons/ubiquiti.svg"> | [AP - Attic](https://eu.store.ui.com/products/unifi-ap-6-lite)                                      | Access Point for my Attic / Upstairs Bedrooms         | -                      |

Most of this stuff is placed in the garage on an old IKEA TV stand that I had in my previous home. The cabinets are filled with cables and other misc. hardware and I have a screen that I plug on every computer there. Should probably think about getting a PiKVM or similar setup.
I prefer to have everything on the garage because it's the coldest room in the house and I avoid having to deal with the noises.

<figure markdown>
  ![homelab](../images/homelab.jpg){ width="500" }
  <figcaption>My humble homelab</figcaption>
</figure>

## TrueNas Scale Box

- Motherboard: [Supermicro X10SLL-F](https://www.supermicro.com/en/products/motherboard/X10SLL-F)
- Processor: Intel Xeon CPU E3-1230 v3 @ 3.30GHz
- Memory: 32 GB ECC RAM
- Boot Disk: [Samsung 850 250GB SSD SATA](https://www.samsung.com/pt/support/model/MZ-75E250B/EU/) (nvme not supported for boot)
- Storage: [6 TB WD Red Plus](https://www.westerndigital.com/pt-br/products/internal-drives/wd-red-plus-sata-3-5-hdd#WD60EFPX) x2 ZFS Pool
- Case: [MarsGaming MC-S1](https://www.amazon.es/-/pt/dp/B0BBR6Z256?psc=1&ref=ppx_yo2ov_dt_b_product_details)
- Power Supply: [Aerocool VX 550](https://www.amazon.es/-/pt/dp/B07HBHPGXF?psc=1&ref=ppx_yo2ov_dt_b_product_details)
- PCI-Express Raid Controller: [Dell Perc H310](https://i.dell.com/sites/doccontent/shared-content/data-sheets/Documents/dell-perc-h310-spec-sheet.pdf)

**Power Consumption:** ~30-60W

<figure markdown>
  ![truenas](../images/truenas-garage.jpg){ width="500" }
  <figcaption>TrueNAS Scale Box</figcaption>
</figure>

The setup is a bit messy, case didn't fit the disks inside so they are outside, I plan to 3D print some case to put them on, but in the meantime they are on top of some cardboard boxes to keep vibration to a minimum.
