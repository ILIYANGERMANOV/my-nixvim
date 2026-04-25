{ ... }: {
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@admin" ];
  };

  # nix-darwin requires zsh to be enabled at the system level for login shells
  programs.zsh.enable = true;
}
