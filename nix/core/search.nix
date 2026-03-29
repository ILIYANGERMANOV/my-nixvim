{ pkgs, ... }:

{
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
  };

  extraPackages = [
    pkgs.ripgrep
    pkgs.fd
  ];
}
