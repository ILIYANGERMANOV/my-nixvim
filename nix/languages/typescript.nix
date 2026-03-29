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
  autoCmd = [
    {
      event = [ "BufRead" "BufNewFile" ];
      pattern = [ "*.mdx" ];
      command = "set filetype=mdx";
    }
  ];

  extraConfigLua = ''
    vim.treesitter.language.register('markdown', 'mdx')
  '';

  plugins = {
    treesitter.grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      typescript
      tsx
      javascript
      html
      css
      markdown
      markdown_inline
    ];

    typescript-tools = {
      enable = true;
      settings = {
        # Tsserver/vtsls options can go here
        expose_as_code_action = "all";
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "all";
          includeInlayFunctionParameterTypeHints = true;
        };
      };
    };

    lsp.servers = {
      biome.enable = true;
      html.enable = true;
      cssls.enable = true;
    };

    nvim-autopairs.settings.ts_config = {
      javascript = [ "string" "template_string" ];
    };

    conform-nvim.settings.formatters_by_ft = {
      typescript = [ "biome" ];
      typescriptreact = [ "biome" ];
      javascript = [ "biome" ];
      javascriptreact = [ "biome" ];
      json = [ "biome" ];
      css = [ "biome" ];
      mdx = [ "biome" ];
    };
  };

  extraPackages = [
    pkgs.nodePackages.typescript-language-server
    pkgs.vscode-langservers-extracted
  ];
}
