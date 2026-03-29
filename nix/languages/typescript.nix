{ pkgs, ... }:

{
  keymaps = [
    {
      mode = "n";
      key = "<leader>oi";
      action = "<cmd>TSToolsRemoveUnused<CR>";
      options.desc = "Clean Unused Imports (TS)";
    }
  ];

  plugins = {
    treesitter = {
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        typescript
        tsx
        javascript
        html
        css
      ];
    };

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
      };
    };
    nvim-autopairs = {
      settings = {
        ts_config = {
          javascript = [ "string" "template_string" ];
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
        };
      };
    };
  };

  extraPackages = [
    pkgs.nodePackages.typescript-language-server
    pkgs.vscode-langservers-extracted
  ];
}
