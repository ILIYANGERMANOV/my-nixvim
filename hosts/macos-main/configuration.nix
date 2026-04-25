{ ... }: {
  networking.hostName = "macos-main";

  myConfig.user = {
    name = "iliyan";
    fullName = "Iliyan Germanov";
    email = "iliyan.germanov971@gmail.com";
  };

  system.stateVersion = 6;
}
