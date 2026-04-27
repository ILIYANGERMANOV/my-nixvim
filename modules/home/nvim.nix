{ root, ... }: {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    imports = [
      (import "${root}/programs/nvim")
    ];
  };
}
