# ─── Nix Darwin ───────────────────────────────────────────────────────────────
# Commands for managing a macOS Nix Darwin configuration.

# Rebuild and switch the system to the latest flake configuration.
darwin-rebuild host:
    darwin-rebuild switch --flake .#{{host}}
