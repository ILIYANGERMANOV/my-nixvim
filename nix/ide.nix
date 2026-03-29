{ pkgs, ... }:

{
  imports = [
    ./languages/typescript.nix
  ];

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
    -- Integration between nvim-autopairs and nvim-cmp
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    local cmp = require('cmp')
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  '';

  keymaps = import ./keymaps.nix;

  autoCmd = [
    {
      event = [ "BufRead" "BufNewFile" ];
      pattern = [ "*.mdc" ];
      callback = {
        __raw = "function() vim.bo.filetype = 'markdown' end";
      };
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
      settings.defaults = {
        file_ignore_patterns = [
          "^node_modules/"
          "^.git/"
          "^dist/"
          "^build/"
          "target/" # For Elixir/Rust
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

    treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
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

    lsp = {
      enable = true;
      servers = {
        nil_ls = {
          enable = true;
          settings = {
            formatting.command = [ "nixpkgs-fmt" ];
            nix.flake.autoArchive = true; # Helps with flake path resolution
          };
        };
      };
    };

    nvim-autopairs = {
      enable = true;
      settings = {
        check_ts = true; # Use treesitter to check for a pair
        ts_config = {
          lua = [ "string" "source" ];
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
    # Elixir Tools
    pkgs.elixir-ls
  ];
}
