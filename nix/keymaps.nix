[
  {
    mode = "n";
    key = "<leader>fg";
    action = "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>";
    options.desc = "Live Grep (Args)";
  }

  { mode = "n"; key = "<leader>h"; action = "<C-w>h"; options.desc = "Focus Left"; }
  { mode = "n"; key = "<leader>l"; action = "<C-w>l"; options.desc = "Focus Right"; }
  { mode = "n"; key = "<leader>j"; action = "<C-w>j"; options.desc = "Focus Down"; }
  { mode = "n"; key = "<leader>k"; action = "<C-w>k"; options.desc = "Focus Up"; }
  { mode = "n"; key = "<leader>H"; action = "<C-w>H"; options.desc = "Move Window Left"; }
  { mode = "n"; key = "<leader>L"; action = "<C-w>L"; options.desc = "Move Window Right"; }
  { mode = "n"; key = "<leader>J"; action = "<C-w>J"; options.desc = "Move Window Down"; }
  { mode = "n"; key = "<leader>K"; action = "<C-w>K"; options.desc = "Move Window Up"; }
  {
    mode = "n";
    key = "<leader>wp";
    action = "<C-w>p";
    options.desc = "Jump to Previous Window";
  }
  # --- TypeScript / Web Tools ---
  {
    mode = "n";
    key = "<leader>e";
    action = "<cmd>lua vim.diagnostic.open_float()<CR>";
    options.desc = "Show line diagnostics";
  }
  {
    mode = "n";
    key = "<leader>fm";
    action = "<cmd>lua require('conform').format()<CR>";
    options.desc = "Format (Biome/Mix)";
  }
  {
    mode = "n";
    key = "<leader>gd";
    action = "<cmd>lua vim.lsp.buf.definition()<CR>";
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
    key = "<leader>cl";
    action = "<cmd>!biome lint .<CR>";
    options.desc = "Check Lint (Biome CLI)";
  }
  {
    mode = "n";
    key = "<leader>rr";
    action = "<cmd>ToggleTerm direction=float name=NodeREPL<CR>node<CR>";
    options.desc = "Node REPL";
  }
  {
    mode = "n";
    key = "<leader>rq";
    action = "<cmd>ToggleTerm<CR>";
    options.desc = "Hide REPL";
  }
  {
    mode = "n";
    key = "<leader>tt";
    action = ''<cmd>lua require("toggleterm").exec("npm test", 1)<CR>'';
    options.desc = "Run Tests (NPM)";
  }

  # --- Elixir Tools ---
  {
    mode = "n";
    key = "<leader>xr";
    action = "<cmd>ToggleTerm direction=float name=IEx<CR>iex -S mix<CR>";
    options.desc = "Elixir REPL (IEx)";
  }
  {
    mode = "n";
    key = "<leader>xt";
    action = ''<cmd>lua require("toggleterm").exec("mix test", 1)<CR>'';
    options.desc = "Run Tests (Mix)";
  }

  {
    mode = "n";
    key = "<leader>ca";
    action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
    options.desc = "Code Actions";
  }
  {
    mode = "n";
    key = "<leader>oi";
    action = "<cmd>TSToolsRemoveUnused<CR>";
    options.desc = "Clean Unused Imports (TS)";
  }
  {
    mode = "n";
    key = "<leader>lx";
    action = "<cmd>lua _G.NuclearTS()<CR>";
    options.desc = "Nuclear TS Restart";
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
  # --- Git ---
  {
    mode = "n";
    key = "<leader>gs";
    action = "<cmd>Neogit<CR>";
    options.desc = "Git Status (Neogit)";
  }
  # --- Terminal mode ---
  {
    mode = "t";
    key = "<Esc>";
    action = "<C-\\><C-n>";
    options.desc = "Exit terminal mode";
  }
]
