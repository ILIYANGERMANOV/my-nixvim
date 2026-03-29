{
  description = "Pre-configured NixVim IDE";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixvim, ... }:
    let
      eachSystem =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
          system: f nixpkgs.legacyPackages.${system}
        );
    in
    {
      devShells = eachSystem (pkgs:
        let
          system = pkgs.stdenv.hostPlatform.system;
          ideModule = import ./nix/ide.nix;
          nvimPkg = nixvim.legacyPackages.${system}.makeNixvimWithModule {
            inherit pkgs;
            module = ideModule;
          };
          basePackages = with pkgs; [
            docker-client
            git
            git-lfs
            nodejs_24
            corepack
            nodePackages.typescript
            nodePackages.typescript-language-server
            nil
            nixpkgs-fmt
          ];
        in
        {
          default = pkgs.mkShell {
            packages = basePackages ++ [ nvimPkg ];

            shellHook = ''
              echo "🔮 NixVim IDE Environment Loaded"
              echo "Run 'nvim' to start."
            '';
          };
        });
    };
}
