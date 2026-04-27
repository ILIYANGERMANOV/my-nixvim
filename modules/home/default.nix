{ pkgs, userConfig, ... }: {
  imports = [
    ./nvim.nix
    ./terminal.nix
    ./claude-code.nix
    ./web-dev.nix
  ];

  home.username = userConfig.name;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/${userConfig.name}"
    else "/home/${userConfig.name}";

  home.stateVersion = "25.11";

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

  home.packages = with pkgs; [
    gh
    wget
    curl
    htop
    firefox
    just
  ];
}
