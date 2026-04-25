{ pkgs, inputs, self }:
let
  system = pkgs.stdenv.hostPlatform.system;
  nvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
    inherit pkgs;
    module = import "${self}/programs/nvim/ide.nix";
    extraSpecialArgs = { profile = "sops"; };
  };
in pkgs.mkShell {
  packages = with pkgs; [
    just        # run Just recipes (just install <host>, just enroll-secure-boot, etc.)
    git         # clone the repo on the live ISO
    age         # age-keygen for generate-age-key recipe
    sbctl       # Secure Boot key creation and enrollment
    nvim        # edit secrets and config files
    sops        # encrypt/decrypt secrets (just edit-secrets, just new-root-password)
    ssh-to-age  # convert SSH host keys to age keys
    whois       # provides mkpasswd for hashing passwords
  ];
  shellHook = ''
    export EDITOR=nvim

    echo "NixOS install shell loaded."
    echo ""
    echo "Quick reference:"
    echo "  just list-disks              — identify the target disk"
    echo "  just install <host>          — full install (disko + age key + secure boot + nixos-install)"
    echo "  just generate-age-key        — generate a fresh age key (key rotation only)"
    echo "  just enroll-secure-boot      — post-boot: enroll keys into UEFI firmware"
    echo "  just rebuild <host>          — post-boot: rebuild and switch"
    echo "  just new-root-password       — hash a new root password and open secrets for editing"
    echo ""
    echo "Run 'just' to list all available recipes."
  '';
}
