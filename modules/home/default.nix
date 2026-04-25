{ pkgs, ... }: {
  imports = [ ./nvim.nix ];

  home.stateVersion = "25.11";

  programs.git = {
    enable = true;
    settings = {
      user.name = "Iliyan Germanov";
      user.email = "iliyan.germanov971@gmail.com";
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
