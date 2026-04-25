{ pkgs, inputs, self }:
let
  system = pkgs.stdenv.hostPlatform.system;
  nvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
    inherit pkgs;
    module = import "${self}/programs/nvim";
    extraSpecialArgs = { profile = "web"; };
  };
in
pkgs.mkShell {
  packages = with pkgs; [
    nvim
    git
    git-lfs
    nil
    nixpkgs-fmt
    nodejs_24
    corepack
    nodePackages.typescript
    nodePackages.typescript-language-server
    docker-client
  ];
  shellHook = ''
    echo "Web IDE loaded — run 'nvim' to start."
  '';
}
