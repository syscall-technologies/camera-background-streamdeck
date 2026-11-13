<div align="center">

<img src="com.sclt.camerabg.sdPlugin/imgs/on@2x.png" width="96" alt="Camera Background key, on">

# Camera Background for Stream Deck

**One key to turn your Mac's camera background on and off.**

[![macOS 15+](https://img.shields.io/badge/macOS-15%2B-000000?logo=apple&logoColor=white)](#requirements)
[![Stream Deck 7.1+](https://img.shields.io/badge/Stream%20Deck-7.1%2B-6E44FF)](#requirements)
[![Dependencies: 0](https://img.shields.io/badge/dependencies-0-brightgreen)](com.sclt.camerabg.sdPlugin/plugin.js)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

</div>

---

<table align="center">
  <tr>
    <td align="center"><img src="com.sclt.camerabg.sdPlugin/imgs/off@2x.png" width="96" alt="off"><br><sub><b>Off</b> · your real background</sub></td>
    <td align="center"><img src="com.sclt.camerabg.sdPlugin/imgs/on@2x.png" width="96" alt="on"><br><sub><b>On</b> · macOS background replacement</sub></td>
  </tr>
</table>

Press the key to switch macOS **Video Effects → Background** for your meeting app (Microsoft Teams by default). The key always shows the real state, even when you change it from Control Center.

## Why this one

- 🎯 **The real switch.** It flips the same setting as Control Center, through the API Control Center itself uses. It doesn't click through menus.
- 👀 **Live icon.** The key checks the state every 2 seconds, so it never drifts.
- 🪶 **Tiny.** Plain JavaScript and macOS's built-in `osascript`. No npm, no build step, no binary.
- 🔒 **No permissions.** No Accessibility, Screen Recording or admin access, and no menu bar icon needed.

## Requirements

- macOS 15 or later (tested on macOS 27.2)
- Stream Deck app 7.1 or later, with any Stream Deck that has keys (tested on a Stream Deck + XL)

## Install

**[⬇ Download Camera Background for Stream Deck](https://github.com/syscall-technologies/camera-background-streamdeck/releases/latest/download/com.sclt.camerabg.streamDeckPlugin)**, then double-click the file. Stream Deck installs it for you.

Then drag **Camera Background → Toggle** onto a key.

<details>
<summary>Install from source instead</summary>

```sh
git clone https://github.com/syscall-technologies/camera-background-streamdeck.git
ln -s "$PWD/camera-background-streamdeck/com.sclt.camerabg.sdPlugin" \
  ~/Library/Application\ Support/com.elgato.StreamDeck/Plugins/
```

Restart the Stream Deck app, then drag **Camera Background → Toggle** onto a key.

</details>

## Using it with another app

Video Effects are set **per app**. Each key controls one app: select the key in Stream Deck and type the app's ID in **App ID**. Leave it empty for Microsoft Teams. You can have one key per app.

To find an app's ID:

```sh
tools/appid.sh            # running apps and their IDs
tools/appid.sh "zoom.us"  # one installed app by name
```

| App | App ID |
|-----|--------|
| Microsoft Teams | `com.microsoft.teams2` |
| Zoom | `us.zoom.xos` |
| FaceTime | `com.apple.FaceTime` |

Browser meetings (Google Meet and others) use the browser's ID, for example `com.google.Chrome`.

## Is it working?

Start a call, then run:

```sh
osascript -l JavaScript com.sclt.camerabg.sdPlugin/bgfx.js status com.microsoft.teams2
```

It prints `on` or `off`, matching the key and Control Center's camera menu. `toggle`, `on` and `off` work too.

## Good to know

> [!WARNING]
> This uses a **private** macOS API (`AVControlCenterModuleState`), the one Control Center uses. Apple can change it in any macOS update. If that happens, the key shows a ⚠️ warning instead of a wrong state.

> [!NOTE]
> The key controls the **Background** effect only, not Portrait (blur) or Studio Light. You still pick the background image in Control Center.

## Hacking

| Path | What |
|------|------|
| [`com.sclt.camerabg.sdPlugin/bgfx.js`](com.sclt.camerabg.sdPlugin/bgfx.js) | Reads and sets the effect through the private API |
| [`com.sclt.camerabg.sdPlugin/plugin.js`](com.sclt.camerabg.sdPlugin/plugin.js) | The plugin: polls the state, toggles on key press |
| [`com.sclt.camerabg.sdPlugin/pi.html`](com.sclt.camerabg.sdPlugin/pi.html) | The App ID setting |
| [`com.sclt.camerabg.sdPlugin/manifest.json`](com.sclt.camerabg.sdPlugin/manifest.json) | Stream Deck manifest |
| [`tools/appid.sh`](tools/appid.sh) | Finds app IDs |
| [`tools/icons.swift`](tools/icons.swift) | Draws the key images from SF Symbols: `swift tools/icons.swift com.sclt.camerabg.sdPlugin/imgs` |

How it works: `AVControlCenterVideoEffectsModuleIsEffectEnabledForBundleID(effect, appID)` reads the state, and `-[AVControlCenterModuleState setEnabled:forVideoEffect:]` sets it. The effect is `AVControlCenterVideoEffectBackgroundReplacement`. Both live in AVFoundation and are called from JavaScript for Automation.

To build the installer, use the [Stream Deck CLI](https://docs.elgato.com/streamdeck/cli/intro) (`npm install -g @elgato/cli`):

```sh
streamdeck validate com.sclt.camerabg.sdPlugin
streamdeck pack com.sclt.camerabg.sdPlugin -o dist
```

To release, push a signed tag: `git tag -s v1.0.1 -m v1.0.1 && git push origin v1.0.1`. The [release workflow](.github/workflows/release.yml) validates, packs and publishes the installer.

## License

[MIT](LICENSE) © 0xSeb
