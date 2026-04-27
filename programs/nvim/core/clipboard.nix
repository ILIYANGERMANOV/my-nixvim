_:

{
  keymaps = [
    {
      mode = "n";
      key = "<leader>fy"; # "Find Yank" 
      action = "<cmd>Telescope neoclip<CR>";
      options.desc = "Clipboard History (Telescope)";
    }
  ];

  clipboard.register = "unnamedplus";

  plugins = {
    neoclip = {
      enable = true;
      settings = {
        history = 100;
      };
    };
  };
}
