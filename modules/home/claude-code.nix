{ root, pkgs, lib, ... }:

let
  claude = import "${root}/programs/claude" { inherit pkgs lib; };
in
{
  home.packages = [ claude.package ];

  home.activation.claudeCodeSettings =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${claude.settingsMerge}/bin/claude-settings-merge "${claude.statusline}/bin/claude-statusline"
    '';
}
