{ pkgs, userConfig, ... }: {
  imports = [
    ./nvim.nix
    ./terminal.nix
  ];

  home.stateVersion = "25.11";

  programs.git = {
    enable = true;
    settings = {
      user.name = userConfig.fullName;
      user.email = userConfig.email;
      init.defaultBranch = "main";
    };
  };

  home.packages = with pkgs; [
    wget
    curl
    htop
    firefox
    just
  ];
}
