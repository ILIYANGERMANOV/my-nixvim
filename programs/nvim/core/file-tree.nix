{ ... }:

{
  plugins = {
    nvim-tree = {
      enable = true;
      settings = {
        update_focused_file = {
          enable = true;
          update_root = true;
        };
      };
    };
  };
}
