# My NixVim IDE

## Setup

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
