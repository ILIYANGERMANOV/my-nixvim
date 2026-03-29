[
  {
    mode = "n";
    key = "<leader>fa";
    action = "<cmd>lua require('telescope.builtin').find_files({ hidden = true, no_ignore = true })<CR>";
    options.desc = "Find All Files (Hidden & Ignored)";
  }
  {
    mode = "n";
    key = "<leader>e";
    action = "<cmd>lua vim.diagnostic.open_float()<CR>";
    options.desc = "Show line diagnostics";
  }
  {
    mode = "n";
    key = "<leader>gd";
    action = "<cmd>Telescope lsp_definitions<CR>";
    options.desc = "Go to Definition";
  }
  {
    mode = "n";
    key = "<leader>gr";
    action = "<cmd>Telescope lsp_references<CR>";
    options.desc = "Find References (Telescope)";
  }
  {
    mode = "n";
    key = "<leader>tt";
    action = ''<cmd>lua require("toggleterm").exec("npm test", 1)<CR>'';
    options.desc = "Run Tests (NPM)";
  }

  {
    mode = "n";
    key = "<leader>ca";
    action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
    options.desc = "Code Actions";
  }
  {
    mode = "n";
    key = "<leader>rn";
    action = "<cmd>lua vim.lsp.buf.rename()<CR>";
    options.desc = "Rename Symbol (LSP)";
  }
  # --- Search & UI ---
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
