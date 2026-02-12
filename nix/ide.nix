{ pkgs, ... }:

{
  colorschemes.catppuccin.enable = true;

  env = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

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

    -- Integration between nvim-autopairs and nvim-cmp
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    local cmp = require('cmp')
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  '';

  keymaps = import ./keymaps.nix;

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
      extensions.live-grep-args.enable = true;
      keymaps = {
        "<leader>ff" = "find_files";
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
        # Elixir Grammars
        elixir
        heex
        eex
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
        # Elixir LSP
        elixirls = {
          enable = true;
        };
      };
    };
    nvim-autopairs = {
      enable = true;
      settings = {
        check_ts = true; # Use treesitter to check for a pair
        ts_config = {
          lua = [ "string" "source" ];
          javascript = [ "string" "template_string" ];
        };
        # This allows it to work with nvim-cmp
        fast_wrap = {
          enable = true;
        };
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
          # Elixir Formatting
          elixir = [ "mix" ];
          heex = [ "mix" ];
          surface = [ "mix" ];
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
    pkgs.nodePackages.typescript-language-server
    pkgs.vscode-langservers-extracted
    # Elixir Tools
    pkgs.elixir-ls
  ];
}
