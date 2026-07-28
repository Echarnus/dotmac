#!/bin/bash
# Tmux status bar LEFT — toolchain versions of the loaded Nix env (devenv / nix-direnv).
#
# These used to be scraped from the project's own manifests (Directory.Build.props,
# global.json, *.csproj, package.json, angular.json). They now come from the Nix profile
# direnv actually loaded for this directory, so the bar reports the toolchain that is
# really on PATH. Adding a language to devenv.nix is all it takes to make it show up here.
#
# Prints nothing outside a Nix environment.

exec "$HOME/dotfiles/bin/nix-toolchain" --tmux "${1:-$PWD}"
