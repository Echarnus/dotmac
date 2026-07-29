#!/usr/bin/env bash
#
# macOS system defaults. Run once on a fresh machine:
#
#   ~/dotfiles/bootstrap/macos-defaults.sh
#
# Every setting here is idempotent, so re-running is safe and is the way to
# re-apply after macOS resets something during a major upgrade.

set -euo pipefail

# ------------------------------------------------------------------- keyboard

# F1–F12 behave as real function keys; the media controls (brightness, volume,
# Mission Control, …) move onto fn+F-key instead. Without this, every F-key an
# editor cares about — F2 rename, F5 run, F12 go-to-definition — needs fn held
# down, which is the wrong default on a machine used for development.
#
# This is read at login. Log out and back in to apply it, or flip it once by
# hand under System Settings → Keyboard → Keyboard Shortcuts → Function Keys,
# which takes effect immediately.
defaults write -g com.apple.keyboard.fnState -bool true

echo "✓ macOS defaults applied."
echo "  Log out and back in for the function-key change to take effect."
