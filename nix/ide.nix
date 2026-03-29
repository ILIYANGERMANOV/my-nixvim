{ pkgs, lib, profile, hpkgs ? null, ... }:

{
  imports = [
    ./core/window.nix
    ./core/theme.nix
    ./core/file-tree.nix
    ./core/git.nix
    ./core/format.nix
    ./core/auto-complete.nix
    ./core/search.nix
    ./core/lsp.nix
    ./core/clipboard.nix
    ./languages/nix.nix
    ./languages/mdc.nix
  ] ++ lib.optionals (profile == "web") [
    ./languages/typescript.nix
  ] ++ lib.optionals (profile == "haskell") [
    (import ./languages/haskell.nix { inherit pkgs lib hpkgs; })
  ];

  env = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  globals = {
    mapleader = " ";
    maplocalleader = " ";
  };

  opts = {
    number = true;
    relativenumber = true;
    shiftwidth = 2;
    expandtab = true;
    smartindent = true;
    breakindent = true;
    ignorecase = true;
    smartcase = true;
  };

  keymaps = import ./keymaps.nix;

  plugins = {
    lualine.enable = true;
  };

  extraPackages = [
    pkgs.xdg-utils
  ];
}
