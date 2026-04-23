{
  description = "Pre-configured NixVim IDE";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixvim, ... }:
    let
      eachSystem =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
          system: f nixpkgs.legacyPackages.${system}
        );
    in
    {
      lib = {
        /** * Neovim (haskell profile) with HLS and tools pinned to `hpkgs`.
         * Usage: my-nixvim.lib.mkHaskellNvim { inherit pkgs hpkgs; }
         */
        mkHaskellNvim = { pkgs, hpkgs }:
          nixvim.legacyPackages.${pkgs.stdenv.hostPlatform.system}.makeNixvimWithModule {
            inherit pkgs;
            module = import "${self}/nix/nvim/ide.nix";
            extraSpecialArgs = {
              profile = "haskell";
              inherit hpkgs;
            };
          };
      };

      devShells = eachSystem (pkgs:
        let
          system = pkgs.stdenv.hostPlatform.system;

          mkNvim =
            profile:
            nixvim.legacyPackages.${system}.makeNixvimWithModule {
              inherit pkgs;
              module = import ./nix/nvim/ide.nix;
              extraSpecialArgs = {
                inherit profile;
              };
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
              echo "🌐 NixVim Web IDE Loaded"
              echo "Run 'nvim' to start."
            '';
          };

          default = web;
        });
    };
}
