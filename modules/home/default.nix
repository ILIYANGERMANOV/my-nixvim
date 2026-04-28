{ pkgs, userConfig, ... }: {
  imports = [
    ./nvim.nix
    ./terminal.nix
    ./claude-code.nix
    ./bitwarden.nix
    ./gitui.nix
    ./languages/typescript.nix
    ./languages/haskell.nix
    ./languages/nix.nix
  ];

  home = {
    username = userConfig.name;
    homeDirectory =
      if pkgs.stdenv.isDarwin
      then "/Users/${userConfig.name}"
      else "/home/${userConfig.name}";
    stateVersion = "25.11";
    packages = with pkgs; [
      gh
      wget
      curl
      htop
      firefox
      just
    ];
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = userConfig.fullName;
      user.email = userConfig.email;
      init.defaultBranch = "main";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    package = pkgs.direnv.overrideAttrs (_: { doCheck = false; });
  };

}
