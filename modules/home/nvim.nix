{ root, ... }: {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    imports = [
      (args@{ pkgs, ... }: import "${root}/programs/nvim/ide.nix" (args // { profile = "web"; }))
    ];
  };
}
