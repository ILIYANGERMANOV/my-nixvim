# ─── Nix Darwin ───────────────────────────────────────────────────────────────
# Commands for managing a macOS Nix Darwin configuration.

# Rebuild and switch the system to the latest flake configuration.
darwin-rebuild host:
    sudo darwin-rebuild switch --flake .#{{host}}

# Dry-run: check the config compiles without applying it.
darwin-build host:
    darwin-rebuild build --flake .#{{host}}

# Roll back to the previous system generation.
darwin-rollback:
    darwin-rebuild rollback

# List all system generations.
darwin-generations:
    darwin-rebuild --list-generations

# Set all three macOS hostname values (required before first bootstrap).
darwin-set-hostname host:
    sudo scutil --set LocalHostName {{host}}
    sudo scutil --set ComputerName {{host}}
    sudo scutil --set HostName {{host}}

# Back up /etc shell files that nix-darwin will replace (required before first bootstrap).
darwin-backup-etc:
    sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
    sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
    sudo mv /etc/zshenv /etc/zshenv.before-nix-darwin

# Bootstrap nix-darwin for the first time on a machine (run after darwin-set-hostname and darwin-backup-etc).
darwin-bootstrap host:
    sudo nix run --extra-experimental-features 'nix-command flakes' \
      'github:nix-darwin/nix-darwin/nix-darwin-25.11#darwin-rebuild' \
      -- switch --flake .#{{host}}
