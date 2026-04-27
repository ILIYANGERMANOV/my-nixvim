{ ... }: {
  networking.hostName = "macos-work";

  myConfig.user = {
    name = "iliyan-coinlist";
    fullName = "Iliyan Germanov";
    email = "iliyan@coinlist.co";
  };

  system.stateVersion = 6;
}
