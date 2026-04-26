{ pkgs }:

let
  # Outputs: "<cyan>dir</cyan>  <green>branch</green>"
  dir = pkgs.writeShellApplication {
    name = "claude-statusline-dir";
    runtimeInputs = with pkgs; [ git ];
    text = ''
      CYAN='\033[38;5;116m'
      GREEN='\033[38;5;114m'
      RESET='\033[0m'

      cwd="''${1:-}"
      [[ -z "$cwd" ]] && exit 0

      dir=$(basename "$cwd")
      git_part=""

      if GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
        branch=$(
          GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null ||
          GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-parse --short HEAD 2>/dev/null ||
          true
        )
        if [[ -n "$branch" ]]; then
          git_part="  ''${GREEN}''${branch}''${RESET}"
        fi
      fi

      printf '%b' "''${CYAN}''${dir}''${RESET}''${git_part}"
    '';
  };

  # Outputs: "  <blue>Claude Sonnet 4.6</blue>"
  model = pkgs.writeShellApplication {
    name = "claude-statusline-model";
    runtimeInputs = [ ];
    text = ''
      BLUE='\033[38;5;111m'
      RESET='\033[0m'

      model="''${1:-}"
      [[ -z "$model" ]] && exit 0

      printf '%b' "  ''${BLUE}''${model}''${RESET}"
    '';
  };

  # Outputs: "  <color>▓▓▓░░ 60% (reset 2h30m)</color>"
  usage = pkgs.writeShellApplication {
    name = "claude-statusline-usage";
    runtimeInputs = with pkgs; [ coreutils ];
    text = ''
      GREY='\033[38;5;245m'
      YELLOW='\033[38;5;215m'
      RED='\033[38;5;210m'
      RESET='\033[0m'

      used_pct="''${1:-}"
      resets_at="''${2:-}"
      [[ -z "$used_pct" ]] && exit 0

      pct=$(printf "%.0f" "$used_pct")

      if [[ "$pct" -ge 80 ]]; then
        ctx_color="$RED"
      elif [[ "$pct" -ge 50 ]]; then
        ctx_color="$YELLOW"
      else
        ctx_color="$GREY"
      fi

      bar_width=5
      filled=$(( pct * bar_width / 100 ))
      empty=$(( bar_width - filled ))
      bar=""
      i=0
      while [[ $i -lt $filled ]]; do bar="''${bar}▓"; i=$(( i + 1 )); done
      i=0
      while [[ $i -lt $empty ]]; do bar="''${bar}░"; i=$(( i + 1 )); done

      reset_part=""
      if [[ -n "$resets_at" ]]; then
        now=$(date +%s)
        mins_left=$(( (resets_at - now) / 60 ))
        if [[ "$mins_left" -gt 0 ]]; then
          if [[ "$mins_left" -ge 60 ]]; then
            reset_part=" (reset $((mins_left / 60))h$((mins_left % 60))m)"
          else
            reset_part=" (reset ''${mins_left}m)"
          fi
        fi
      fi

      printf '%b' "  ''${ctx_color}''${bar} ''${pct}%''${reset_part}''${RESET}"
    '';
  };

  # Outputs: "  <badge> 30k / 200k (15%) </badge>"
  tokens = pkgs.writeShellApplication {
    name = "claude-statusline-tokens";
    runtimeInputs = [ ];
    text = ''
      RESET='\033[0m'

      ctx_size="''${1:-}"
      used_pct="''${2:-}"
      [[ -z "$ctx_size" || -z "$used_pct" ]] && exit 0

      pct=$(printf "%.0f" "$used_pct")
      toks=$(( ctx_size * pct / 100 ))
      toks_k=$(( toks / 1000 ))
      ctx_k=$(( ctx_size / 1000 ))

      if [[ "$pct" -ge 80 ]]; then
        printf '%b' "  \033[1;38;5;210m⚠ ''${toks_k}k / ''${ctx_k}k (''${pct}%)''${RESET}"
      elif [[ "$pct" -ge 50 ]]; then
        printf '%b' "  \033[1;38;5;215m~ ''${toks_k}k / ''${ctx_k}k (''${pct}%)''${RESET}"
      else
        printf '%b' "  \033[38;5;114m''${toks_k}k / ''${ctx_k}k (''${pct}%)''${RESET}"
      fi
    '';
  };

in
# Orchestrator: reads JSON from stdin, dispatches to sub-scripts, assembles output.
pkgs.writeShellApplication {
  name = "claude-statusline";
  runtimeInputs = [ pkgs.jq dir model usage tokens ];
  text = ''
    input=$(cat)

    cwd=$(printf '%s' "$input"          | jq -r '.workspace.current_dir // .cwd // empty')
    model=$(printf '%s' "$input"        | jq -r '.model.display_name // .model.id // empty')
    used_pct=$(printf '%s' "$input"     | jq -r '.rate_limits.five_hour.used_percentage // empty')
    resets_at=$(printf '%s' "$input"    | jq -r '.rate_limits.five_hour.resets_at // empty')
    ctx_size=$(printf '%s' "$input"     | jq -r '.context_window.context_window_size // empty')
    ctx_used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')

    dir_part=$(claude-statusline-dir      "$cwd")
    model_part=$(claude-statusline-model  "$model")
    usage_part=$(claude-statusline-usage  "$used_pct" "$resets_at")
    tokens_part=$(claude-statusline-tokens "$ctx_size" "$ctx_used_pct")

    printf '%s\n' "''${dir_part}''${model_part}''${usage_part}''${tokens_part}"
  '';
}
