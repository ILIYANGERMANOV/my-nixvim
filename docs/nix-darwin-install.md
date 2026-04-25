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

### 2.3 Back up existing `/etc` shell files

nix-darwin will replace `/etc/zshrc` and `/etc/bashrc` with its own versions. It attempts to back them up automatically, but this can fail with a "refusing to clobber" error if the backup file already exists. Pre-empt it manually:

```bash
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
```

**Why now and not later?** If you skip this and the auto-backup fails mid-bootstrap, you'll need to abort, move the files, and re-run the entire bootstrap. Doing it now costs nothing.

> [!NOTE]
> Between this step and completing the bootstrap, any new terminal you open may be missing some default macOS PATH entries (the original `/etc/zshrc` is gone). Keep your current terminal open and don't open new ones until after step 3.2.

### 2.4 Clone the repo

```bash
git clone <repo-url> ~/ivy-apps/repo/nixos
cd ~/ivy-apps/repo/nixos
```

---

## Part 3 — Bootstrap nix-darwin (first time only)

`darwin-rebuild` doesn't exist yet — it's installed *by* nix-darwin. The bootstrap command runs it once directly from the flake without installing anything permanently first.

### 3.1 Build the system closure

```bash
sudo nix run --extra-experimental-features 'nix-command flakes' 'github:nix-darwin/nix-darwin/nix-darwin-25.11#darwin-rebuild' -- switch --flake .#macos-main
```

**Why pin the branch?** The `flake.nix` in this repo pins nix-darwin to the `nix-darwin-25.11` branch to match `nixpkgs/nixos-25.11`. Using the unversioned `github:nix-darwin/nix-darwin` will fetch whatever the default branch currently is, which may be a newer release — nix-darwin enforces a hard version match with nixpkgs and will abort with a mismatch error if they differ.

**Why this instead of `darwin-rebuild switch`?** `darwin-rebuild` is provided by nix-darwin itself. On a fresh machine it doesn't exist yet. `nix run` builds and runs it from the flake input in a temporary environment without permanently installing it.

**What happens:** This command builds the full system closure (nix-darwin activation scripts, home-manager, all packages), then attempts to activate. The build phase runs as your user. The activation phase requires root and will fail with:

```
system activation must now be run as root
```

This is expected — note the store path printed in the error (e.g. `/nix/store/…-darwin-rebuild/bin/darwin-rebuild`). You need it for the next step.

> [!NOTE]
> The build downloads a large amount of packages on first run. Expect 5–20 minutes depending on your connection.

### 3.2 Activate as root

Take the store path from the error in step 3.1 and run activation as root:

```bash
sudo /nix/store/<hash>-darwin-rebuild/bin/darwin-rebuild switch --flake .#macos-main
```

**Why two steps?** Recent nix-darwin requires the activation script to run as root because it writes to `/etc`, `/run/current-system`, and registers launchd services. Running the full `nix run` command under `sudo` fails because `sudo` drops your user environment including the `nix` binary from `PATH`. The split — build as user, activate as root via the already-built store path — is the reliable workaround.

**What activation does:**
1. Patches `/etc/zshrc`, `/etc/bashrc`, and `/etc/shells` to source Nix and nix-darwin profile scripts.
2. Creates symlinks under `/run/current-system`.
3. Activates home-manager for your user.
4. Registers any launchd services declared in the config.

### 3.3 Reload your shell

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

### nix-darwin / nixpkgs version mismatch

```
error: nix-darwin now uses release branches that correspond to Nixpkgs releases.
       You are currently using nix-darwin 26.05 with Nixpkgs 25.11.
```

This happens when `github:nix-darwin/nix-darwin` (unversioned) is used in `flake.nix` and the default branch has advanced to a newer release. Fix it by ensuring the branch in `flake.nix` matches the nixpkgs branch:

```nix
nix-darwin = {
  url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";   # must match nixpkgs branch
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Then update the lock entry and retry:

```bash
nix flake update nix-darwin
nix run 'github:nix-darwin/nix-darwin/nix-darwin-25.11#darwin-rebuild' -- switch --flake .#macos-main
```

### `system activation must now be run as root`

This is expected behaviour in recent nix-darwin — activation writes to `/etc` and `/run/current-system` and requires root. The build phase (the slow part) already completed successfully. Grab the store path from the error output and run activation directly:

```bash
sudo /nix/store/<hash>-darwin-rebuild/bin/darwin-rebuild switch --flake .#macos-main
```

**Why not `sudo nix run ...`?** `sudo` drops your user environment, removing `nix` from `PATH`. The store path bypasses this entirely.

### `/etc/zshrc` conflict error

```
error: refusing to clobber existing file '/etc/zshrc'
```

You skipped step 2.3. Move the files manually and re-run activation:

```bash
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
sudo mv /etc/zshenv /etc/zshenv.before-nix-darwin
```

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
