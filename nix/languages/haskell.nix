{ pkgs, ... }:

{
  keymaps = [
    {
      mode = "n";
      key = "<leader>tt";
      action = ''<cmd>lua require("toggleterm").exec("cabal test --test-show-details=direct", 1)<CR>'';
      options.desc = "Run Cabal Tests";
    }
    {
      mode = "n";
      key = "<leader>rr";
      action = ''<cmd>lua require("toggleterm").exec("cabal repl", 1)<CR>'';
      options.desc = "Haskell REPL";
    }
    {
      mode = "n";
      key = "<leader>hg";
      action = "<cmd>Telescope hoogle<CR>";
      options.desc = "Hoogle (Live)";
    }
    {
      mode = "n";
      key = "<leader>lx";
      action = "<cmd>lua _G.HlsRestart()<CR>";
      options.desc = "Restart Haskell LSP (HLS)";
    }
  ];

  extraConfigLua = ''
    require("telescope").load_extension("hoogle")

    _G.HlsRestart = function()
      vim.lsp.stop_client(vim.lsp.get_active_clients({ name = 'hls' }))
      vim.cmd('edit')
      vim.notify("♻️  HLS Restarted", vim.log.levels.INFO)
    end
  '';

  autoCmd = [
    {
      event = [ "BufEnter" "CursorHold" "InsertLeave" ];
      pattern = [ "*.hs" ];
      callback = {
        __raw = "function() vim.lsp.codelens.refresh() end";
      };
    }
  ];

  plugins = {
    treesitter.grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      haskell
    ];

    lsp = {
      capabilities = "require('cmp_nvim_lsp').default_capabilities()";

      servers.hls = {
        enable = true;
        package = null;
        installGhc = false;
        filetypes = [ "haskell" "lhaskell" "cabal" ];
        settings = {
          haskell = {
            formattingProvider = "fourmolu";
            plugin = {
              importLens = { globalOn = true; };
              alternateNumberFormat = { globalOn = true; };
              "ghcide-type-lenses" = { globalOn = true; };
              "ghcide-code-actions-fill-hole" = { globalOn = true; };
              "ghcide-code-actions-imports-exports" = { globalOn = true; };
            };
          };
        };
      };

      keymaps.extra = [
        {
          key = "<leader>cA";
          action = "vim.lsp.codelens.run";
          options.desc = "Run CodeLens";
        }
      ];
    };

    conform-nvim.settings.formatters_by_ft.haskell = [ "fourmolu" ];
  };

  extraPlugins = [
    pkgs.vimPlugins.telescope_hoogle
  ];
}
