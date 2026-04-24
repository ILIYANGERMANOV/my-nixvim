# NixOS Install Guide

Step-by-step guide for installing (or re-installing) NixOS on a machine using disko for declarative disk partitioning and LUKS2 full-disk encryption.

> [!WARNING]
> Every disko step is **destructive** — it wipes and reformats the target disk. Double-check the device name before running anything.

---

## Overview of what you'll end up with

```
/dev/nvme0n1  (GPT)
├── ESP  (1 MB → 1 GB)   vfat  →  /boot
└── root (1 GB → 100%)   LUKS2 (passphrase-protected)
                          └── btrfs
                              ├── /root  →  /
                              ├── /home  →  /home
                              ├── /nix   →  /nix
                              └── /log   →  /var/log
```

---

## Part 1 — Set up a new host in the repo

Skip this part if you are re-installing an existing host.

### 1.1 Create the host directory

```
hosts/<new-host>/
├── configuration.nix
└── disk-config.nix
```

### 1.2 Write `disk-config.nix`

Copy `hosts/lenovo-old/disk-config.nix` and change:

- `device` — the block device on the target machine (find it with `lsblk`).

Everything else (partition sizes, LUKS2 cipher/KDF args, LUKS name, btrfs label, subvolumes, mount options) can stay identical. The LUKS `name` and btrfs label are only per-machine identifiers — they only need to differ if you ever physically attach two host disks to the same machine at the same time.

### 1.3 Register the host in `flake.nix`

```nix
nixosConfigurations = {
  lenovo-old = lib.mkNixosSystem "lenovo-old" "x86_64-linux";
  new-host   = lib.mkNixosSystem "new-host"   "x86_64-linux";
};
```

### 1.4 Write `configuration.nix`

```nix
{ config, pkgs, lib, modulesPath, root, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disk-config.nix
  ];

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "aesni_intel" "cryptd" ];

  networking.hostName = "new-host";
  networking.networkmanager.enable = true;

  sops.defaultSopsFile = "${root}/secrets/secrets.yaml";

  system.stateVersion = "25.11";
}
```

> Tip: check `dmesg | grep -E 'nvme|ahci|xhci'` on a live ISO to confirm which kernel modules your hardware needs.

### 1.5 Commit and push

Push the new host config before you boot into the live ISO — you'll clone it from there.

---

## Part 2 — Install on the machine

### 2.1 Boot a NixOS live ISO

Download from https://nixos.org/download and write it to a USB drive. Boot the target machine from it.

### 2.2 Identify the target disk

```bash
lsblk
```

Confirm the device name (e.g. `/dev/nvme0n1`, `/dev/sda`). Make sure it matches what's in `disk-config.nix`.

### 2.3 Clone the repo

```bash
nix-shell -p git --run "git clone <repo-url> /tmp/nixos-config"
cd /tmp/nixos-config
```

### 2.4 Partition, format, and mount (destructive)

```bash
sudo nix run github:nix-community/disko -- \
  --mode disko \
  hosts/<hostname>/disk-config.nix
```

This will:
1. Wipe and re-partition the disk (GPT).
2. Format the ESP as vfat.
3. Create the LUKS2 container — **you will be prompted for a passphrase. Choose a strong one and do not lose it.**
4. Format the inner volume as btrfs with subvolumes.
5. Mount everything under `/mnt`.

### 2.5 Set up the SOPS age key

The age key must exist on disk before `nixos-install` can activate any SOPS secrets. Do this now, while `/mnt` is mounted.

First, create the directory:

```bash
sudo mkdir -p /mnt/var/lib/sops-age
sudo chmod 700 /mnt/var/lib/sops-age
```

Then follow **one** of the two paths below depending on whether this is a new host or a reinstall.

---

#### Path A — New host (no existing key)

Generate a fresh key:

```bash
sudo nix-shell -p age --run "age-keygen -o /mnt/var/lib/sops-age/keys.txt"
sudo chmod 600 /mnt/var/lib/sops-age/keys.txt
```

Print the public key:

```bash
sudo grep 'public key' /mnt/var/lib/sops-age/keys.txt
```

**Save the entire `/mnt/var/lib/sops-age/keys.txt` file to BitWarden now** (secure note), before you do anything else. If the disk is ever wiped you will have no other copy.

You will also need the public key in step 2.10 to authorise this machine in `.sops.yaml`.

---

#### Path B — Reinstall (key already exists in BitWarden)

Retrieve the `keys.txt` content from BitWarden and write it to disk. Do **not** use a file — write directly so the key never touches `/tmp` or shell history:

```bash
sudo mkdir -p /mnt/var/lib/sops-age/
sudo nano /mnt/var/lib/sops-age/keys.txt
sudo grep 'public key' /mnt/var/lib/sops-age/keys.txt
```

No changes to `.sops.yaml` are needed — the key is the same one already authorised.

---

### 2.6 Create Secure Boot keys

lanzaboote needs the PKI bundle to exist before `nixos-install` can sign the boot files. Create the keys now while `/mnt` is still mounted:

```bash
sudo mkdir -p /mt/etc/secureboot/
sudo nix-shell -p sbctl --run "sbctl --disable-landlock create-keys --export /mnt/etc/secureboot"
```

### 2.7 Install NixOS

```bash
sudo nixos-install --flake /tmp/nixos-config#<hostname> --no-root-passwd
```

This builds the system closure, copies it into `/mnt/nix/store`, and writes the lanzaboote-signed bootloader.

### 2.8 Reboot

```bash
sudo reboot
```

Remove the USB drive. The machine will boot into NixOS and prompt for the LUKS passphrase.

### 2.9 Enroll Secure Boot keys

After logging in, enroll the keys into the UEFI firmware:

```bash
sudo sbctl enroll-keys --microsoft
```

The `--microsoft` flag includes Microsoft's certificates, which are required by most firmware to boot option ROMs and external devices.

Then reboot, enter the UEFI firmware settings (usually F2/DEL/F12 during POST), and **enable Secure Boot**. From this point on the firmware will reject any unsigned or tampered bootloader, kernel, or initrd.

### 2.10 Authorise the new age key in SOPS

After the machine is up, follow **`docs/SOPS.md` → "Adding a new machine (new age key)"** to add the public key to `.sops.yaml`, re-encrypt secrets, commit, and push.

Then on the machine:

```bash
sudo nixos-rebuild switch --flake /path/to/repo#<hostname>
```

---

## Part 3 — Re-installing an existing host (destructive wipe)

Re-installing is identical to Part 2. There is nothing special to do in the repo — the host config already exists.

In step 2.5 use **Path B** (restore from BitWarden). The key stays the same, so `.sops.yaml` does not need updating and step 2.8 can be skipped.

---

## Mounting without reformatting

If you need to mount an already-formatted disk (e.g. you rebooted into a live ISO mid-install), use `--mode mount` instead of `--mode disko`:

```bash
sudo nix run github:nix-community/disko -- \
  --mode mount \
  hosts/<hostname>/disk-config.nix
```

This opens the LUKS container and mounts all btrfs subvolumes under `/mnt` without touching the partition table or formatting anything.

---

## LUKS passphrase

The LUKS passphrase is the **only** credential protecting the encrypted volume. There is no recovery key, no keyfile, and no escrow. If the passphrase is lost the data is unrecoverable.

The initrd prompts for it on every boot before the root filesystem is mounted.
