{ ... }:

{
  plugins = {
    diffview.enable = true;
    neogit = {
      enable = true;
      settings.integrations.diffview = true;
    };
    gitsigns.enable = true;
  };
}
