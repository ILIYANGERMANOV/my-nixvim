{ config, pkgs, lib, modulesPath, root, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disk-config.nix
  ];

  # lanzaboote replaces systemd-boot to provide Secure Boot signing
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "aesni_intel" "cryptd" ];
  boot.kernelModules = [ "kvm-intel" ];

  networking.hostName = "lenovo-old";
  networking.networkmanager.enable = true;

  sops.defaultSopsFile = "${root}/secrets/secrets.yaml";
  sops.secrets.iliyan-password = { neededForUsers = true; };

  users.mutableUsers = false;
  users.users.iliyan = {
    isNormalUser = true;
    description = "Iliyan";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    hashedPasswordFile = config.sops.secrets.iliyan-password.path;
  };

  home-manager.users.iliyan = import "${root}/modules/home/default.nix";

  system.stateVersion = "25.11";
}
