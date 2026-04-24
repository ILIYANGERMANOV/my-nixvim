# My NixOS (experimental toy project)

This is a personal playground for experimenting with NixOS. I don't run it on production or my primary machine — the configuration is rough, likely has security vulnerabilities, and is not intended for anyone else to use.

---

> [!WARNING]
> ## SECURITY DISCLAIMER & PERSONAL USE NOTICE
>
> **This repository is my personal, experimental NixOS and NixVim configuration. It is NOT intended for production use, public deployment, or adoption by others.**
>
> - **USE AT YOUR OWN RISK.** This configuration may contain security vulnerabilities, incomplete hardening, experimental settings, or unsafe defaults that are intentionally or unintentionally present for my own convenience during development.
> - **NO WARRANTY.** I make absolutely no guarantees about the correctness, safety, or stability of anything in this repository. Configurations may break your system, expose sensitive data, or behave in unexpected ways.
> - **NOT SECURITY-AUDITED.** SOPS secrets management, disk encryption settings, SSH configuration, and any other security-sensitive components have NOT been independently audited. Do not assume they are safe or correct.
> - **NOT MAINTAINED FOR OTHERS.** This repo evolves for my personal needs. Breaking changes, incomplete states, and half-finished experiments are normal and expected.
> - **DO NOT USE THIS ON PRODUCTION SYSTEMS.** This is a lab/experimentation environment. It is explicitly not designed to be reproducible, secure, or safe outside of my own machines.
>
> If you are looking for a well-maintained, production-safe NixOS configuration, please look elsewhere. See the [LICENSE](./LICENSE) for full liability disclaimers.

---

## NeoVim Setup

### Install Nix from https://github.com/DeterminateSystems/nix-installer

### Install [iTerm2](https://iterm2.com/)

### Optimize MacOS keyboard
Since you are on MacOS, the default keyboard "Repeat Rate" is often too slow for Vim navigation (holding `j` to scroll down will feel sluggish).

1. Open **System Settings** -> **Keyboard**.
2. Set **Key repeat rate** to **Fast** (Max).
3. Set **Delay until repeat** to **Short** (Max).

*This makes moving around with `h` `j` `k` `l` feel instantaneous.*

### Configure iTerm2

```shell
brew install --cask iterm2
brew install --cask font-jetbrains-mono-nerd-font
```

**iTerm2 Settings:**
1. Open iTerm
2. Settings > Profiles > Text.
3. Check "Use a different font for non-ASCII text".
4. Select the `JetBrainsMono Nerd Font`.
