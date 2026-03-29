{
  description = "Pre-configured NixVim IDE";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
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

          mkNvim = profile: nixvim.legacyPackages.${system}.makeNixvimWithModule {
            inherit pkgs;
            module = import ./nix/ide.nix;
            extraSpecialArgs = { inherit profile; };
          };

          basePackages = with pkgs; [
            git
            git-lfs
            nil
            nixpkgs-fmt
          ];

          webPackages = basePackages ++ (with pkgs; [
            nodejs_24
            corepack
            nodePackages.typescript
            nodePackages.typescript-language-server
            docker-client
          ]);
        in
        rec {
          web = pkgs.mkShell {
            packages = webPackages ++ [ (mkNvim "web") ];
            shellHook = ''
              echo "🌐 NixVim Web Environment Loaded"
              echo "Run 'nvim' to start."
            '';
          };

          haskell = pkgs.mkShell {
            packages = [ (mkNvim "haskell") ];
            shellHook = ''
              echo "λ NixVim Haskell Environment Loaded"
              echo "Run 'nvim' to start."
            '';
          };

          default = web;
        });
    };
}
