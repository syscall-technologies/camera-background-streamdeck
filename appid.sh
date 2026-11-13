#!/bin/sh
# Find an app's bundle ID for bgfx / the Stream Deck key.
#   ./appid.sh               list running apps with their IDs
#   ./appid.sh "Zoom"        print the ID of an installed app by name
if [ $# -eq 0 ]; then
  osascript -e 'tell application "System Events" to set ps to every process whose background only is false' \
    -e 'set out to ""' \
    -e 'repeat with p in ps' \
    -e 'tell application "System Events" to set out to out & (name of p) & tab & (bundle identifier of p) & linefeed' \
    -e 'end repeat' -e 'return out' | sort | column -t -s "$(printf '\t')"
else
  osascript -e "id of app \"$1\""
fi
