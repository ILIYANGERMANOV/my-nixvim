{ pkgs, ... }:

{
  # fontconfig is Linux-only; macOS locates fonts via ~/Library/Fonts automatically
  fonts.fontconfig.enable = pkgs.stdenv.isLinux;

  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then null else pkgs.ghostty;
    enableZshIntegration = true;

    settings = {
      theme = "tokyonight";
      font-family = "JetBrainsMono Nerd Font";
      font-size = 13;

      window-decoration = true;
      # Maps Option to Alt so Neovim keybinds work on macOS; ignored on Linux
      macos-option-as-alt = true;
      macos-window-shadow = true;

      scrollback-limit = 10000;
      copy-on-select = true;
      mouse-hide-while-typing = true;

      keybind = [
        "ctrl+t=new_tab"
        "ctrl+w=close_surface"
        "ctrl+tab=next_tab"
        "ctrl+shift+enter=new_split:right"
        "ctrl+shift+down=new_split:down"
        "ctrl+left=goto_split:left"
        "ctrl+right=goto_split:right"
      ];
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      g = "git";
      gs = "git status";
      nv = "nvim";
      ls = "eza --icons";
      ll = "eza -alF --icons";
      cd = "z";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
    };
  };

  home.packages = with pkgs; [
    eza
    zoxide
    fzf
    ripgrep
    fd
    jq
    nerd-fonts.jetbrains-mono
  ];
}
