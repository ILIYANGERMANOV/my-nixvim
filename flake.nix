{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, nixvim, ... }:
    let
      eachSystem =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = eachSystem (pkgs:
        let
          ideModule = import ./nix/ide.nix;
          nvimPkg = nixvim.legacyPackages.${pkgs.system}.makeNixvimWithModule {
            inherit pkgs;
            module = ideModule;
          };

          basePackages = [
            pkgs.docker-client
            pkgs.git
            pkgs.git-lfs
            pkgs.nodejs_24
            pkgs.corepack
            pkgs.nodePackages.typescript
            pkgs.nodePackages.typescript-language-server
            pkgs.nil # The Nix Language Server
            pkgs.nixpkgs-fmt
          ];
        in
        {
          default = pkgs.mkShell {
            packages = basePackages ++ [ nvimPkg ];

            shellHook = ''
              echo "🔮NixVim IDE Environment Loaded"
              echo "Run 'nvim' to start."
            '';
          };
        });
    };
}
