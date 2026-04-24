{ inputs, root, ... }: {
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.sharedModules = [ inputs.nixvim.homeModules.nixvim ];
  home-manager.extraSpecialArgs = { inherit root; };
}
