# ─── Nix Darwin — Install ────────────────────────────────────────────────────
# One-time setup commands for bootstrapping nix-darwin on a new macOS machine.

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
