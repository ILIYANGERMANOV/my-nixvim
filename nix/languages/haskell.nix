{ pkgs, ... }:

{
  extraConfigLua = ''
    require("telescope").load_extension("hoogle")

    _G.HlsRestart = function()
      for _, client in ipairs(vim.lsp.get_clients({ name = "hls" })) do
        vim.lsp.stop_client(client.id)
      end
      vim.cmd("edit")
      vim.notify("HLS restarted", vim.log.levels.INFO)
    end
  '';

  keymaps = [
    {
      mode = "n";
      key = "<leader>lx";
      action = "<cmd>lua _G.HlsRestart()<CR>";
      options.desc = "Restart Haskell LSP (HLS)";
    }
  ];

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
