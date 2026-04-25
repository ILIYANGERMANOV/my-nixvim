{ inputs, root, config, ... }: {
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.sharedModules = [ inputs.nixvim.homeModules.nixvim ];
  home-manager.extraSpecialArgs = {
    inherit root;
    userConfig = config.myConfig.user;
  };
}
