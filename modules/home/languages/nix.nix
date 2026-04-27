{ pkgs, ... }:
{
  home.packages = [
    pkgs.nil
    pkgs.nixpkgs-fmt
  ];
}
