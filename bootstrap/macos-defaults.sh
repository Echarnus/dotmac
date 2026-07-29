#!/usr/bin/env bash
#
# macOS system defaults. Run once on a fresh machine:
#
#   ~/dotfiles/bootstrap/macos-defaults.sh
#
# Every setting here is idempotent, so re-running is safe and is the way to
# re-apply after macOS resets something during a major upgrade.
#
# NIX-FIRST NOTE: per AGENTS.md this file is interim scaffolding. Every setting
# below maps to a nix-darwin `system.defaults.*` option; porting this script is a
# wanted change. It is a shell script today only because nix-darwin isn't set up
# on the machine yet, and an inert .nix file restores nothing on reinstall day.
#
# These were captured by sweeping the live preference domains and keeping the
# values that differ from Apple's stock defaults. macOS records no "changed vs
# default" anywhere, so treat the list as thorough rather than provably complete.

set -euo pipefail

# ----------------------------------------------------------------- appearance

# Dark mode.
defaults write -g AppleInterfaceStyle -string "Dark"

# Show all file extensions in Finder.
defaults write -g AppleShowAllExtensions -bool true

# ------------------------------------------------------------------- keyboard

# F1–F12 behave as real function keys; the media controls (brightness, volume,
# Mission Control, …) move onto fn+F-key instead. Without this, every F-key an
# editor cares about — F2 rename, F5 run, F12 go-to-definition — needs fn held
# down, which is the wrong default on a machine used for development.
#
# The Keychron K10 presents as an Apple keyboard (vendor id 0x05AC) when its
# Mac/Windows switch is on Mac, so this OS-level setting governs it. Keychron's
# own fn+X+L combo is Windows-mode only and does not apply.
defaults write -g com.apple.keyboard.fnState -bool true

# ----------------------------------------------------------------------- dock

defaults write com.apple.dock autohide -bool true      # auto-hide the Dock
defaults write com.apple.dock launchanim -bool false   # no bouncing launch animation
defaults write com.apple.dock mineffect -string "scale" # scale, not genie
defaults write com.apple.dock tilesize -int 46

# --------------------------------------------------------------------- finder

defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"  # list view
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false

# ------------------------------------------------- desktop & window behaviour

# Hide desktop icons. AeroSpace tiles everything; a visible desktop is noise.
defaults write com.apple.WindowManager HideDesktop -bool true

# Don't reveal the desktop when clicking the wallpaper — with a tiling WM this
# fires constantly by accident.
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# No margins around macOS-tiled windows (AeroSpace manages gaps itself).
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

# ----------------------------------------------------------------- screenshots

# Screenshots go to the clipboard rather than littering the Desktop.
defaults write com.apple.screencapture target -string "clipboard"

# ------------------------------------------------------------------- activate

# Apply without requiring a logout. This is what nix-darwin's activation phase
# does, and it is what makes the function-key change take effect immediately —
# `defaults write` alone is otherwise only read at login.
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u || true

# Dock and Finder read their prefs at launch.
killall Dock >/dev/null 2>&1 || true
killall Finder >/dev/null 2>&1 || true

echo "✓ macOS defaults applied (and activated — no logout needed)."

# ---------------------------------------------------------------------------
# Deliberately NOT captured here:
#
#   - Locale (en_BE, AppleLanguages en-BE/nl-BE). Set during macOS setup; more
#     natural to pick in the installer than to force from a script.
#   - Dock contents (`persistent-apps`). A blob of absolute app paths that goes
#     stale as soon as an app moves; re-pinning by hand takes a minute.
#   - Disabled keyboard shortcuts (`com.apple.symbolichotkeys`, 13 entries —
#     ids 15–26 plus 164, the accessibility zoom/contrast block). Stored as a
#     nested plist that does not round-trip cleanly through `defaults write`.
#     Capture with:
#       defaults export com.apple.symbolichotkeys ~/dotfiles/macos/symbolichotkeys.plist
#   - Anything identifying: account ids, paired Bluetooth devices, network
#     names, analytics timestamps.
# ---------------------------------------------------------------------------
