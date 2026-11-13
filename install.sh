#!/bin/sh
# Build bgfx into the plugin and link the plugin into Stream Deck (re-run after moving the repo or a macOS update).
set -eu
cd "$(dirname "$0")"
PLUGIN=com.seb.camerabg.sdPlugin
mkdir -p "$PLUGIN/bin"
clang -O2 -fobjc-arc -framework Foundation bgfx.m -o "$PLUGIN/bin/bgfx"
"$PLUGIN/bin/bgfx" status >/dev/null # fails here if the private API is gone
DEST="$HOME/Library/Application Support/com.elgato.StreamDeck/Plugins/$PLUGIN"
[ -L "$DEST" ] || [ ! -e "$DEST" ] || { echo "$DEST exists and is not a symlink; remove it first" >&2; exit 1; }
ln -sfn "$PWD/$PLUGIN" "$DEST"
pkill -x "Stream Deck" || true
sleep 2
open -a "Elgato Stream Deck"
echo "installed: add 'Camera Background > Toggle Background' to a key"
