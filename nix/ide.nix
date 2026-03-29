{ pkgs, ... }:

{
  imports = [
    ./core/window.nix
    ./core/theme.nix
    ./core/file-tree.nix
    ./core/git.nix
    ./core/auto-complete.nix
    ./languages/typescript.nix
    ./languages/nix.nix
  ];

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
  };

  clipboard.register = "unnamedplus";

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
    telescope = {
      enable = true;
      settings.defaults = {
        file_ignore_patterns = [
          "^node_modules/"
          "^.git/"
          "^dist/"
          "^build/"
          "target/"
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
        bash
        dockerfile
      ];
    };

    lsp = {
      enable = true;
    };

    comment.enable = true;
    lualine.enable = true;
  };

  extraPackages = [
    pkgs.ripgrep
    pkgs.fd
    pkgs.nixpkgs-fmt
    pkgs.xdg-utils
  ];
}
