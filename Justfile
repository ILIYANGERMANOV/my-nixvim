set shell := ["bash", "-eo", "pipefail", "-c"]

import 'just/live-iso.just'
import 'just/secrets.just'
import 'just/post-boot.just'

# Show available recipes
default:
    @just --list
