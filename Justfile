set shell := ["bash", "-eo", "pipefail", "-c"]

import 'just/live-iso.just'
import 'just/secrets.just'
import 'just/post-boot.just'
import 'just/nix-darwin/install.just'
import 'just/nix-darwin/post-install.just'

# Show available recipes
default:
    @just --list
