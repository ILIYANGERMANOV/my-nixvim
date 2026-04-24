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
        "${root}/modules/nixos/common.nix"
        "${root}/modules/nixos/desktop.nix"
        "${root}/modules/nixos/audio.nix"
        "${root}/modules/nixos/sops.nix"
        "${root}/modules/nixos/home-manager.nix"
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

in {
  inherit mkNixosSystem forAllSystems mkHaskellNvim;
}
