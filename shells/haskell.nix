{ pkgs, inputs, self }:
let
  system = pkgs.stdenv.hostPlatform.system;
  hpkgs = pkgs.haskellPackages;
  nvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
    inherit pkgs;
    module = import "${self}/programs/nvim/ide.nix";
    extraSpecialArgs = {
      profile = "haskell";
      inherit hpkgs;
    };
  };
in pkgs.mkShell {
  packages = with pkgs; [
    nvim
    git
    git-lfs
    nil
    nixpkgs-fmt
    hpkgs.cabal-install
    hpkgs.haskell-language-server
    hpkgs.fourmolu
    hpkgs.hlint
    (hpkgs.ghcWithPackages (_: []))
  ];
  shellHook = ''
    echo "Haskell IDE loaded — run 'nvim' to start."
  '';
}
