#!/usr/bin/env bash
#
# Installs Microsoft's official .NET SDK into ~/.dotnet, for VS Code's C#
# extensions only. Run once on a fresh machine:
#
#   ~/dotfiles/bootstrap/vscode-dotnet-sdk.sh [channel]     # default channel: 10.0
#
# ---------------------------------------------------------------------------
# Why this exists — and why it does NOT contradict the "no global toolchains"
# rule in the Brewfile.
#
# C# Dev Kit's server binary is signed by Microsoft and runs under the macOS
# hardened runtime. It cannot dlopen libhostfxr.dylib from a Nix-provided SDK,
# because Nix signs its libraries ad-hoc with no Team Identifier. macOS refuses
# the load outright:
#
#   code signature ... not valid for use in process: mapping process and mapped
#   file (non-platform) have different Team IDs
#   .NET server exited with 130
#
# The failure is silent in the editor. Dev Kit still logs that it is opening the
# solution — to a server that already died — and Roslyn falls back to treating
# every .cs file as a standalone program under a synthetic Canonical.csproj. The
# symptom is that Go to Definition works inside a file but not across projects.
#
# So this SDK exists purely to satisfy the editor's code-signing requirement. It
# is deliberately NOT added to PATH: terminal and CI builds keep using the
# per-repo devenv/Nix SDK, so build behaviour is unchanged and two projects can
# still pin different .NET versions. Only VS Code's C# extensions are pointed
# here, via "dotnetAcquisitionExtension.existingDotnetPath" in
# vscode/.config/Code/User/settings.json.
#
# Same class of exception as SQLcl and Docker Desktop: a tool that cannot come
# from Nix, installed out of band and documented as such.
# ---------------------------------------------------------------------------

set -euo pipefail

CHANNEL="${1:-10.0}"
INSTALL_DIR="$HOME/.dotnet"
SCRIPT="$(mktemp -t dotnet-install)"

cleanup() { rm -f "$SCRIPT"; }
trap cleanup EXIT

echo "→ Installing .NET SDK (channel $CHANNEL) into $INSTALL_DIR …"
curl -sSL https://dot.net/v1/dotnet-install.sh -o "$SCRIPT"
chmod +x "$SCRIPT"
"$SCRIPT" --channel "$CHANNEL" --install-dir "$INSTALL_DIR" --no-path

echo
echo "→ SDKs now available to the editor:"
"$INSTALL_DIR/dotnet" --list-sdks

# The entire point of this script is the signature. Verify it rather than
# assume it — an ad-hoc signed hostfxr here would reproduce the original bug.
echo
if codesign -dv --verbose=2 "$INSTALL_DIR"/host/fxr/*/libhostfxr.dylib 2>&1 |
     grep -q "Authority=Developer ID Application: Microsoft Corporation"; then
  echo "✓ libhostfxr.dylib carries Microsoft's Developer ID signature — C# Dev Kit can load it."
else
  echo "✗ libhostfxr.dylib is NOT Developer ID signed. C# Dev Kit will still fail to start."
  exit 1
fi

cat <<'EOF'

Next: make sure VS Code points at it. In vscode/.config/Code/User/settings.json:

  "dotnetAcquisitionExtension.existingDotnetPath": [
    { "extensionId": "ms-dotnettools.csdevkit", "path": "<HOME>/.dotnet/dotnet" },
    { "extensionId": "ms-dotnettools.csharp",   "path": "<HOME>/.dotnet/dotnet" }
  ]

The setting needs a real absolute path — "~" is not expanded — so if this machine's
home directory differs from the one in the committed snapshot, fix the paths there.
Then fully quit VS Code (Cmd+Q) and reopen; a window reload is not enough.
EOF
