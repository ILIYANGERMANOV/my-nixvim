_: {
  networking.hostName = "macos-work";

  # Determinate Nix manages its own daemon — disable nix-darwin's Nix management to avoid conflict.
  nix.enable = false;

  myConfig.user = {
    name = "iliyan-coinlist";
    fullName = "Iliyan Germanov";
    email = "iliyan@coinlist.co";
  };

  system.stateVersion = 6;
}
