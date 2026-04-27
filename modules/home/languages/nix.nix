{ pkgs, ... }:
{
  home.packages = [
    pkgs.nil
    pkgs.nixpkgs-fmt
    pkgs.statix
    pkgs.deadnix
    pkgs.nix-tree
  ];
}
