#!/usr/bin/env bash
# Install a login LaunchAgent that runs bin/tmux-workspaces, so the tmux sessions
# exist after every boot. Idempotent: rewrites the plist and reloads the agent.
set -euo pipefail

label=it.clercq.tmux-workspaces
plist="$HOME/Library/LaunchAgents/$label.plist"

mkdir -p "$HOME/Library/LaunchAgents"
cat > "$plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>$label</string>
	<key>ProgramArguments</key>
	<array>
		<string>$HOME/dotfiles/bin/tmux-workspaces</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>StandardOutPath</key>
	<string>/tmp/$label.log</string>
	<key>StandardErrorPath</key>
	<string>/tmp/$label.log</string>
</dict>
</plist>
PLIST

domain="gui/$(id -u)"
launchctl bootout "$domain/$label" 2>/dev/null || true
launchctl bootstrap "$domain" "$plist"
echo "installed $label"
