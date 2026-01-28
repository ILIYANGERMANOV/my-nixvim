{ pkgs, ... }:

{
  colorschemes.catppuccin.enable = true;

  globals = {
    mapleader = " ";
    maplocalleader = " ";
  };

  opts = {
    number = true;
    relativenumber = true;
    shiftwidth = 2;
    expandtab = true;
    smartindent = true;
    breakindent = true;
    ignorecase = true;
    smartcase = true;

    # --- Window/Split Behavior ---
    splitbelow = true;
    splitright = true;
    termguicolors = true;
  };

  clipboard.register = "unnamedplus";

  extraConfigLua = ''
    -- Nuclear TypeScript Reset
    -- Kills the TSServer client and forces a restart
    _G.NuclearTS = function()
      local notify = vim.notify
      notify("☢️  Initiating TypeScript Nuclear Reset...", vim.log.levels.WARN)

      local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
      local clients = get_clients({ name = "typescript-tools" }) -- or "ts_ls"

      if #clients == 0 then
         -- Fallback if using standard lspconfig
         clients = get_clients({ name = "ts_ls" })
      end

      for _, client in ipairs(clients) do
        client.stop()
      end

      vim.defer_fn(function()
        vim.cmd("LspStart typescript-tools")
        vim.cmd("LspStart ts_ls")
        notify("✅ TS Server Revived.", vim.log.levels.INFO)
      end, 1000)
    end
  '';

  keymaps = [
    { mode = "n"; key = "<leader>h"; action = "<C-w>h"; options.desc = "Focus Left"; }
    { mode = "n"; key = "<leader>l"; action = "<C-w>l"; options.desc = "Focus Right"; }
    { mode = "n"; key = "<leader>j"; action = "<C-w>j"; options.desc = "Focus Down"; }
    { mode = "n"; key = "<leader>k"; action = "<C-w>k"; options.desc = "Focus Up"; }
    { mode = "n"; key = "<leader>H"; action = "<C-w>H"; options.desc = "Move Window Left"; }
    { mode = "n"; key = "<leader>L"; action = "<C-w>L"; options.desc = "Move Window Right"; }
    { mode = "n"; key = "<leader>J"; action = "<C-w>J"; options.desc = "Move Window Down"; }
    { mode = "n"; key = "<leader>K"; action = "<C-w>K"; options.desc = "Move Window Up"; }

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
      options.desc = "Format (Biome)";
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
      options.desc = "Run Tests";
    }
    {
      mode = "n";
      key = "<leader>ca";
      action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
      options.desc = "Code Actions";
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
  ];

  plugins = {
    web-devicons.enable = true;
    nvim-tree = {
      enable = true;
      settings = {
        update_focused_file = {
          enable = true;
          update_root = true;
        };
      };
    };
    diffview.enable = true;

    toggleterm = {
      enable = true;
      settings = {
        direction = "horizontal";
        size = ''
          function(term)
            return vim.o.lines * 0.3
          end
        '';
        open_mapping = "[[<c-t>]]";
        hide_numbers = true;
        shade_terminals = true;
        start_in_insert = true;
        terminal_mappings = true;
        persist_mode = true;
        insert_mappings = true;
      };
    };

    neogit = {
      enable = true;
      settings.integrations.diffview = true;
    };

    telescope = {
      enable = true;
      keymaps = {
        "<leader>ff" = "find_files";
        "<leader>fg" = "live_grep";
      };
    };

    treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        typescript
        tsx
        javascript
        html
        css
        json
        yaml
        markdown
        nix
        bash
        dockerfile
      ];
    };

    # The TypeScript equivalent of haskell-tools (supercharged LSP)
    typescript-tools = {
      enable = true;
      settings = {
        # Tsserver/vtsls options can go here
        expose_as_code_action = "all";
      };
    };

    # Biome LSP primarily for linting details inside editor
    lsp = {
      enable = true;
      servers = {
        biome.enable = true;
        html.enable = true;
        cssls.enable = true;
        # Note: ts_ls is disabled because we use typescript-tools above
      };
    };

    conform-nvim = {
      enable = true;
      settings = {
        format_on_save = { timeout_ms = 2000; lsp_fallback = true; };
        formatters_by_ft = {
          typescript = [ "biome" ];
          typescriptreact = [ "biome" ];
          javascript = [ "biome" ];
          javascriptreact = [ "biome" ];
          json = [ "biome" ];
          css = [ "biome" ];
          nix = [ "nixpkgs_fmt" ];
        };
      };
    };

    cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        sources = [{ name = "nvim_lsp"; } { name = "path"; } { name = "buffer"; } { name = "luasnip"; }];
        mapping = {
          # Use Tab to cycle through suggestions
          "<Tab>" = "cmp.mapping.select_next_item()";
          "<S-Tab>" = "cmp.mapping.select_prev_item()";

          # IntelliJ-style: Enter replaces the existing text
          "<CR>" = ''
            cmp.mapping.confirm({
              behavior = cmp.ConfirmBehavior.Replace,
              select = true,
            })
          '';

          # Optional: Use Shift+Enter to just insert (without replacing)
          "<S-CR>" = ''
            cmp.mapping.confirm({
              behavior = cmp.ConfirmBehavior.Insert,
              select = true,
            })
          '';
        };
      };
    };
    luasnip.enable = true;
    gitsigns.enable = true;
    comment.enable = true;
    lualine.enable = true;
  };

  extraPackages = [
    pkgs.ripgrep
    pkgs.fd
    pkgs.nixpkgs-fmt
    pkgs.xdg-utils
    pkgs.biome
    pkgs.nodePackages.typescript-language-server
    pkgs.vscode-langservers-extracted
  ];
}
