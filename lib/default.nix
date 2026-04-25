{ inputs, root }:
let
  inherit (inputs.nixpkgs) lib;

  mkNixosSystem = hostname: system:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs root; };
      modules = [
        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.home-manager
        inputs.lanzaboote.nixosModules.lanzaboote
        "${root}/modules/nixos/common.nix"
        "${root}/modules/nixos/desktop.nix"
        "${root}/modules/nixos/audio.nix"
        "${root}/modules/nixos/security/sops.nix"
        "${root}/modules/nixos/security/disk-encryption.nix"
        "${root}/modules/nixos/security/secure-boot.nix"
        "${root}/modules/nixos/user.nix"
        "${root}/modules/nixos/home-manager.nix"
        "${root}/hosts/${hostname}/configuration.nix"
      ];
    };

  mkDarwinSystem = hostname: system:
    inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit inputs root; };
      modules = [
        inputs.home-manager.darwinModules.home-manager
        "${root}/modules/macos/common.nix"
        "${root}/modules/macos/user.nix"
        "${root}/modules/macos/home-manager.nix"
        "${root}/hosts/${hostname}/configuration.nix"
      ];
    };

  forAllSystems = f:
    lib.genAttrs
      [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ]
      (system: f (import inputs.nixpkgs { inherit system; }));

  mkHaskellNvim = { pkgs, hpkgs }:
    inputs.nixvim.legacyPackages.${pkgs.stdenv.hostPlatform.system}.makeNixvimWithModule {
      inherit pkgs;
      module = import "${root}/programs/nvim/ide.nix";
      extraSpecialArgs = {
        profile = "haskell";
        inherit hpkgs;
      };
    };

in
{
  inherit mkNixosSystem mkDarwinSystem forAllSystems mkHaskellNvim;
}
