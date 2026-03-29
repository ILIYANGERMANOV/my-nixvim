[
  {
    mode = "n";
    key = "<leader>tt";
    action = ''<cmd>lua require("toggleterm").exec("npm test", 1)<CR>'';
    options.desc = "Run Tests (NPM)";
  }
  {
    mode = "n";
    key = "<leader>bk";
    action = "<cmd>bd<CR>";
    options.desc = "Kill Buffer";
  }
  # --- Terminal mode ---
  {
    mode = "t";
    key = "<Esc>";
    action = "<C-\\><C-n>";
    options.desc = "Exit terminal mode";
  }
]
