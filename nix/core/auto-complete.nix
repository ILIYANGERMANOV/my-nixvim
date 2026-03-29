{ ... }:

{
  extraConfigLua = ''
    -- Integration between nvim-autopairs and nvim-cmp
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    local cmp = require('cmp')
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  '';

  plugins = {
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
  };
}
