{ pkgs, ... }: {
  programs.gitui = {
    enable = true;

    # Tokyo Night theme — matches Ghostty + Neovim
    theme = ''
      (
          selected_tab: Reset,
          command_fg: Some(Rgb(192, 202, 245)),   // fg       #c0caf5
          selection_bg: Some(Rgb(61, 89, 161)),   // blue0    #3d59a1
          selection_fg: Some(Rgb(192, 202, 245)), // fg       #c0caf5
          cmdbar_bg: Some(Rgb(22, 22, 30)),        // bg_dark  #16161e
          cmdbar_extra_lines_bg: Some(Rgb(22, 22, 30)),
          disabled_fg: Some(Rgb(86, 95, 137)),    // comment  #565f89
          diff_line_add: Some(Rgb(158, 206, 106)),  // green  #9ece6a
          diff_line_delete: Some(Rgb(247, 118, 142)), // red  #f7768e
          diff_file_added: Some(Rgb(115, 218, 202)),  // green1 #73daca
          diff_file_removed: Some(Rgb(219, 75, 75)),  // red1   #db4b4b
          diff_file_moved: Some(Rgb(187, 154, 247)),  // magenta #bb9af7
          diff_file_modified: Some(Rgb(224, 175, 104)), // yellow #e0af68
          commit_hash: Some(Rgb(187, 154, 247)),   // magenta #bb9af7
          commit_time: Some(Rgb(125, 207, 255)),   // cyan    #7dcfff
          commit_author: Some(Rgb(158, 206, 106)), // green   #9ece6a
          danger_fg: Some(Rgb(247, 118, 142)),     // red     #f7768e
          push_gauge_bg: Some(Rgb(122, 162, 247)), // blue    #7aa2f7
          push_gauge_fg: Some(Rgb(26, 27, 38)),    // bg      #1a1b26
          tag_fg: Some(Rgb(187, 154, 247)),        // magenta #bb9af7
          branch_fg: Some(Rgb(224, 175, 104)),     // yellow  #e0af68
      )
    '';
  };
}
