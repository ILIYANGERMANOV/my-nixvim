# Official claude-plugins-official LSP plugins to enable globally.
# Each entry maps to a plugin in the Anthropic marketplace; the binary
# for that plugin must already be on PATH (managed separately via Home Manager).
{
  enabled = {
    "typescript-lsp@claude-plugins-official" = true;
  };
}
