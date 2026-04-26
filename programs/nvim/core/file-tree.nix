{ ... }:

{
  keymaps = [
    {
      mode = "n";
      key = "<leader>ft";
      action = "<cmd>NvimTreeToggle<CR>";
      options.desc = "File Tree";
    }
  ];

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
