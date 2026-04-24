{ config, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # --- System-wide Git Configuration ---
  programs.git = {
    enable = true;
    config = {
      user = {
        name = "Iliyan Germanov";
        email = "iliyan.germanov971@gmail.com";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };

  # --- NixVim Integration ---
  programs.nixvim = {
    enable = true;

    # Makes your custom NixVim the default editor for git commits, sudo, etc.
    defaultEditor = true;

    imports = [
      ({ pkgs, lib, config, ... }@args: import ../../programs/nvim/ide.nix (args // { profile = "web"; }))
    ];
  };
  # --- Bootloader ---
  # Matches your Disko UEFI configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];

  # --- Networking ---
  networking.hostName = "lenovo-old";
  networking.networkmanager.enable = true;


  # --- Graphical Desktop Environment ---
  # Enable the X11 windowing system and KDE Plasma 6 (Wayland)
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Enable sound with Pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- SOPS Configuration ---
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/var/lib/sops-age/keys.txt";

  sops.secrets.iliyan-password = {
    neededForUsers = true;
  };

  # --- User Configuration ---
  users.mutableUsers = false;

  users.users.iliyan = {
    isNormalUser = true;
    description = "Iliyan";
    # Added video and audio groups for standard desktop permissions
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];

    hashedPasswordFile = config.sops.secrets.iliyan-password.path;
  };
  # --- SSH & Security ---
  # Explicitly disable remote access
  services.openssh.enable = false;

  # --- System Packages ---
  # Allow unfree packages (often necessary for web browsers or hardware drivers)
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    firefox

    # Handy utilities
    wget
    curl
    htop

    # Install sops and age globally so you can encrypt/decrypt files
    # natively on the new machine without needing a nix-shell
    sops
    age
  ];

  # --- Nix Daemon Settings ---
  # Enable Flakes permanently on the system
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Automatically clean up and optimize the Nix store to save space
  nix.settings.auto-optimise-store = true;

  # DO NOT CHANGE: Used for state migrations
  system.stateVersion = "25.11";
}
