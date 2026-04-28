{ pkgs, inputs, self }:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  nvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
    inherit pkgs;
    module = import "${self}/programs/nvim";
    extraSpecialArgs = { profile = "nix"; };
  };
  claudeCode = import "${self}/programs/claude-code" { inherit pkgs; };
in
pkgs.mkShell {
  packages = with pkgs; [
    just        # run darwin-install recipes
    git         # clone / work with the repo
    nvim        # edit host config and flake.nix before bootstrapping
    nil         # Nix LSP (inside nvim)
    nixpkgs-fmt # Nix formatter (inside nvim)
  ] ++ claudeCode.packages;
  shellHook = ''
    ${claudeCode.activationScript}
    echo "Darwin install shell loaded."
    echo ""
    echo "Quick reference:"
    echo "  just darwin-set-hostname <host>  — set all three macOS hostname values"
    echo "  just darwin-backup-etc           — back up /etc shell files nix-darwin will replace"
    echo "  just darwin-bootstrap <host>     — first-time bootstrap (runs darwin-rebuild via nix run)"
    echo "  just darwin-rebuild <host>       — rebuild and switch after config changes"
    echo "  just darwin-rollback             — roll back to the previous generation"
    echo ""
    echo "Run 'just' to list all available recipes."
  '';
}
