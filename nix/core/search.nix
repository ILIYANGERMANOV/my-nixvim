{ pkgs, ... }:

{
  keymaps = [
    {
      mode = "n";
      key = "<leader>fa";
      action = "<cmd>lua require('telescope.builtin').find_files({ hidden = true, no_ignore = true })<CR>";
      options.desc = "Find All Files (Hidden & Ignored)";
    }
    {
      mode = "n";
      key = "<leader>ss";
      action = "<cmd>Telescope current_buffer_fuzzy_find<CR>";
      options.desc = "Search in Buffer";
    }
    {
      mode = "n";
      key = "<leader>nh";
      action = "<cmd>noh<CR>";
      options.desc = "Clear Highlights";
    }
  ];

  plugins = {
    telescope = {
      enable = true;
      settings.defaults = {
        file_ignore_patterns = [
          "^node_modules/"
          "^.git/"
          "^dist/"
          "^build/"
          "target/"
        ];
      };
      extensions = {
        live-grep-args.enable = true;
        ui-select.enable = true;
      };
      keymaps = {
        "<leader>ff" = "find_files";
        "<leader>fg" = "live_grep_args";
      };
    };
  };

  extraPackages = [
    pkgs.ripgrep
    pkgs.fd
  ];
}
