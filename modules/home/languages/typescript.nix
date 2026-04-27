{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nodejs_24
    pnpm
    nodePackages.typescript-language-server
    vscode-langservers-extracted
    biome
  ];
}
