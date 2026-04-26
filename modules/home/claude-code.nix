{ root, pkgs, lib, ... }:

let
  claude = import "${root}/programs/claude-code" { inherit pkgs lib; };
in
{
  home.packages = [ claude.package ];

  home.activation.claudeCodeSettings =
    lib.hm.dag.entryAfter [ "writeBoundary" ] claude.activationScript;
}
