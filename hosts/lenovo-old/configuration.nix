{ config, pkgs, modulesPath, root, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disk-config.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];

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
