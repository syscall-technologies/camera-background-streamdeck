# macOS camera background on a Stream Deck key

Toggle macOS **Video Effects → Background** (the background replacement in Control Center) from a Stream Deck key. The key's icon shows the current state, and it also updates when you change the background from Control Center.

| Off | On |
|-----|----|
| ![off](com.seb.camerabg.sdPlugin/imgs/off@2x.png) | ![on](com.seb.camerabg.sdPlugin/imgs/on@2x.png) |

No clicking through the UI, no Accessibility permission, and no menu bar icon needed: `bgfx` calls the same private AVFoundation function Control Center uses.

> **Private API warning.** Tested on macOS 27.2 with Stream Deck 7.6.1. Apple can change or remove this API in any update. When that happens, `bgfx` exits with `private Video Effects API not found` and the key shows a warning triangle instead of failing silently.

## Requirements

- macOS 15 or later (Video Effects Background); tested on 27.2
- Xcode Command Line Tools (`xcode-select --install`), for `clang`
- Stream Deck app 6.5 or later (the plugin uses its bundled Node 24)

## Install

```sh
./install.sh
```

The script builds `bgfx` into the plugin, symlinks the plugin into Stream Deck's plugin folder, and restarts Stream Deck. Then drag **Camera Background → Toggle Background** onto a key.

Re-run `./install.sh` after moving the repo or after a macOS update.

## Choosing the app

Video Effects are stored **per app**. The key defaults to Microsoft Teams (`com.microsoft.teams2`). For another app, select the key and enter its **App ID** in the Stream Deck settings panel. Each key can target a different app.

To find an app's ID:

```sh
./appid.sh            # list running apps and their IDs
./appid.sh "zoom.us"  # ID of an installed app by name
```

## Command line

`bgfx` also works on its own:

```sh
com.seb.camerabg.sdPlugin/bin/bgfx status                 # on | off   (Teams)
com.seb.camerabg.sdPlugin/bin/bgfx toggle                 # flip it, prints the new state
com.seb.camerabg.sdPlugin/bin/bgfx on  us.zoom.xos        # force on for Zoom
com.seb.camerabg.sdPlugin/bin/bgfx off us.zoom.xos        # force off for Zoom
```

Exit codes: `0` ok, `1` the change didn't stick, `2` private API not found, `64` bad usage.

## How it works

- Reading the state: `AVControlCenterVideoEffectsModuleIsEffectEnabledForBundleID(effect, bundleID)`, exported by AVFoundation.
- Writing the state: `-[AVControlCenterModuleState setEnabled:forVideoEffect:]` on `+[AVControlCenterModuleState moduleStateForBundleID:]`.
- The effect is the `AVControlCenterVideoEffectBackgroundReplacement` constant.

The plugin (`plugin.js`, plain Node with no dependencies) checks `bgfx status` every 2 seconds for each key and runs `bgfx toggle` when you press the key.

## Files

| Path | What |
|------|------|
| `bgfx.m` | The CLI that reads and sets the Background effect |
| `appid.sh` | Finds app bundle IDs |
| `install.sh` | Builds and installs the plugin |
| `com.seb.camerabg.sdPlugin/` | Stream Deck plugin: manifest, `plugin.js`, `pi.html` (settings panel), icons |
| `tools/make-icons.swift` | Regenerates the key icons from SF Symbols: `swift tools/make-icons.swift` |

## Not covered

- Portrait (blur), Studio Light and the other effects. `bgfx` only handles Background. The other effect constants exist (`AVControlCenterVideoEffectBackgroundBlur`, …) if you want to extend it.
- Choosing the background image. That still happens in Control Center.

## Uninstall

```sh
rm "$HOME/Library/Application Support/com.elgato.StreamDeck/Plugins/com.seb.camerabg.sdPlugin"
```

Then restart Stream Deck.
