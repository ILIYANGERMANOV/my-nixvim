set shell := ["bash", "-eo", "pipefail", "-c"]

import 'just/nixos/live-iso.just'
import 'just/nixos/secrets.just'
import 'just/nixos/post-boot.just'
import 'just/nix-darwin/install.just'
import 'just/nix-darwin/post-install.just'

# Show available recipes
default:
    @just --list
