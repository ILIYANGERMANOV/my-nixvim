{ pkgs, ... }:

{

  plugins = {
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
        bash
        dockerfile
      ];
    };

    lsp = {
      enable = true;
    };

    comment.enable = true;
  };
}
