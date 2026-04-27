{ ... }: {
  networking.hostName = "macos-work";

  myConfig.user = {
    name = "iliyangermanov";
    fullName = "Iliyan Germanov";
    email = "iliyan@coinlist.co";
  };

  system.stateVersion = 6;
}
