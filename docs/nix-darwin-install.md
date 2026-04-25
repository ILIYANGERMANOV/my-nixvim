# Nix Darwin Install Guide

Step-by-step guide for bootstrapping nix-darwin on a Mac using the `macos-main` host configuration already defined in this repo.

> [!NOTE]
> nix-darwin brings declarative macOS system configuration — the same model as NixOS but for macOS. It manages `/etc` files, system packages, user environments (via home-manager), launchd services, and shell integration without touching anything not declared in the config.

---

## Overview of what you'll end up with

```
macOS (Apple Silicon or Intel)
├── nix-darwin system activation  →  /run/current-system
├── home-manager user environment →  ~/.nix-profile
│   ├── NeoVim (nixvim, web profile)
│   ├── Ghostty terminal
│   ├── Zsh + Starship + eza/zoxide/fzf/ripgrep
│   └── JetBrainsMono Nerd Font
└── darwin-rebuild CLI            →  rebuild the system after config changes
```

---

## Part 1 — Install Nix

Skip this part if Nix is already installed (`nix --version` prints something).

### 1.1 Install with the Determinate Systems installer

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

**Why this installer?** The official Nix installer leaves behind a multi-step mess to uninstall. The Determinate Systems installer (`nix-installer`) is fully reversible (`nix-installer uninstall`), sets up multi-user mode automatically, and enables flakes out of the box — no manual `nix.conf` editing needed.

After installation, open a **new terminal** (or `source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`) so the `nix` command is on your PATH.

Verify:

```bash
nix --version
```

---

## Part 2 — Prepare the machine

### 2.1 Check your architecture

```bash
uname -m
```

- `arm64` → Apple Silicon → config uses `aarch64-darwin` ✓ (already set in `flake.nix`)
- `x86_64` → Intel Mac → change `flake.nix` `darwinConfigurations` entry to `"x86_64-darwin"`

### 2.2 Set the hostname

The hostname on the machine must match `networking.hostName = "macos-main"` in the config. nix-darwin reads the hostname to find the right `darwinConfigurations` entry when you omit `--flake`.

```bash
sudo scutil --set LocalHostName macos-main
sudo scutil --set ComputerName macos-main
sudo scutil --set HostName macos-main
```

**Why three commands?** macOS has three separate hostname values: `LocalHostName` (Bonjour/mDNS), `ComputerName` (Finder/Sharing), and `HostName` (BSD kernel). nix-darwin's `networking.hostName` sets all three during activation, but you need them correct *before* the first build so the initial `darwin-rebuild` can match the config.

Verify:

```bash
scutil --get LocalHostName   # should print: macos-main
```

### 2.3 Clone the repo

```bash
git clone <repo-url> ~/ivy-apps/repo/nixos
cd ~/ivy-apps/repo/nixos
```

---

## Part 3 — Bootstrap nix-darwin (first time only)

`darwin-rebuild` doesn't exist yet — it's installed *by* nix-darwin. The bootstrap command runs it once directly from the flake without installing anything permanently first.

### 3.1 Run the bootstrap build

```bash
nix run 'github:nix-darwin/nix-darwin#darwin-rebuild' -- switch --flake ~/ivy-apps/repo/nixos#macos-main
```

**Why this instead of `darwin-rebuild switch`?** `darwin-rebuild` is provided by nix-darwin itself. On a fresh machine it doesn't exist yet. `nix run` builds and runs it from the flake input in a temporary environment without permanently installing it — after a successful switch the real `darwin-rebuild` binary is in your PATH for all future rebuilds.

**What this does:**
1. Evaluates `darwinConfigurations.macos-main` from the flake.
2. Builds the full system closure (nix-darwin activation scripts, home-manager, all packages).
3. Activates the system: patches `/etc/zshrc`, `/etc/bashrc`, and `/etc/shells`; creates symlinks under `/run/current-system`; activates home-manager for your user.

> [!NOTE]
> nix-darwin will detect existing macOS-managed `/etc/zshrc` (and similar files) and **back them up** automatically with a `.before-nix-darwin` suffix before replacing them. This is safe — your original files are preserved.

> [!NOTE]
> The build downloads a large amount of packages on first run. Expect 5–20 minutes depending on your connection.

### 3.2 Reload your shell

```bash
source /etc/zshrc
```

**Why?** The bootstrap modifies `/etc/zshrc` to source the Nix and nix-darwin profile scripts. Your current shell session predates those changes, so you need to reload it (or just open a new terminal tab).

Verify `darwin-rebuild` is now available:

```bash
which darwin-rebuild   # should print a path under /run/current-system
darwin-rebuild --version
```

---

## Part 4 — Verify the setup

### 4.1 Check NeoVim

```bash
nvim --version
```

Neovim should launch with the Catppuccin theme, nvim-tree, Telescope, LSP, and all plugins from `programs/nvim/`.

### 4.2 Check Ghostty

Ghostty is installed as a macOS app via home-manager. Find it in:

```
~/.nix-profile/Applications/Ghostty.app
```

Or open it with:

```bash
open ~/.nix-profile/Applications/Ghostty.app
```

**Why is it not in `/Applications`?** home-manager installs GUI apps into `~/.nix-profile/Applications/`. Spotlight indexes this path, so you can launch Ghostty from Spotlight (`⌘ Space → Ghostty`). If Spotlight doesn't find it yet, run `mdimport ~/.nix-profile/Applications/`.

### 4.3 Check the font

```bash
fc-list | grep -i jetbrains
```

The JetBrainsMono Nerd Font must be present for Neovim devicons to render correctly.

---

## Part 5 — Day-to-day usage

### Rebuild after config changes

```bash
cd ~/ivy-apps/repo/nixos
darwin-rebuild switch --flake .#macos-main
```

**Why `switch` and not `build`?** `build` only builds the new closure without activating it — useful to test that the config evaluates cleanly. `switch` builds *and* activates immediately. Use `build` first if you want a dry-run, then `switch` to apply.

### Dry-run (check the config compiles without applying)

```bash
darwin-rebuild build --flake .#macos-main
```

### Roll back to the previous generation

```bash
darwin-rebuild rollback
```

**Why this is safe:** nix-darwin keeps every previous system generation. `rollback` switches the symlink back to the prior generation's activation script — your packages and configuration are instantly reverted without rebuilding anything.

### List all generations

```bash
darwin-rebuild --list-generations
```

---

## Troubleshooting

### `/etc/zshrc` conflict error

```
error: refusing to clobber existing file '/etc/zshrc'
```

nix-darwin found the original macOS file without a `.before-nix-darwin` backup already present. Move it manually:

```bash
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
sudo mv /etc/zshenv /etc/zshenv.before-nix-darwin
```

Then re-run the bootstrap command from step 3.1.

### `darwin-rebuild: command not found` after bootstrap

The bootstrap activated nix-darwin but your current shell doesn't see it yet. Reload:

```bash
source /etc/zshrc
```

Or open a new terminal.

### Nix daemon not running

```
error: cannot connect to daemon at '/nix/var/nix/daemon-socket/socket'
```

The Nix daemon launchd service didn't start. Start it manually:

```bash
sudo launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist
```

If that fails, re-run the Determinate Systems installer — it handles daemon registration.

### Wrong architecture in `flake.nix`

If you're on an Intel Mac and the build errors with an architecture mismatch, edit `flake.nix`:

```nix
darwinConfigurations = {
  macos-main = lib.mkDarwinSystem "macos-main" "x86_64-darwin";
};
```

Then re-run step 3.1.
