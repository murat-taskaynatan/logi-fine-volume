# logi-fine-volume

Fine-grained macOS volume control for Logitech keyboards using Logi Options+.

This project builds three tiny macOS helper apps:

- `Logi Fine Volume Down.app`
- `Logi Fine Volume Up.app`
- `Logi Fine Volume Hotkeys.app`

The recommended path is the hotkey helper. It runs in the background, listens for two Logi-assigned keystrokes, changes the system output volume by an exact step, and shows a small custom HUD.

## Why this exists

Some Logitech keyboards on macOS, including MX-series devices, send media keys through Logi Options+ in a way that does not reliably reach Karabiner as raw keyboard events. The result is that:

- normal media volume works
- Karabiner remaps may not trigger
- custom shortcut fallbacks may beep instead of being handled

This repo avoids that path by using a local background helper instead of Logitech's normal media-key flow.

The generated helper apps are native Swift bundles. They do not use the AppleScript applet runtime, which helps avoid the visible blink and focus disturbance that can happen when launching hidden AppleScript apps repeatedly.

## Repo layout

- `src/volume_common.swift`
- `src/volume_runner.swift`
- `src/volume_hotkeys.swift`
- `src/volume_hud.swift`
- `scripts/build_apps.sh`
- `INSTRUCTIONS.md`

## Requirements

- macOS
- Logi Options+
- `osascript` available on the system
- `xcrun swiftc` available on the system

## Build

Run:

```sh
./scripts/build_apps.sh
```

The generated output will be written to:

```text
dist/Logi Fine Volume Down.app
dist/Logi Fine Volume Up.app
dist/Logi Fine Volume Hotkeys.app
dist/com.murat-taskaynatan.logi-fine-volume.hotkeys.plist
```

Each generated app contains:

- a native binary that sets the new exact volume
- a small background HUD binary that displays the current volume percentage

## Install

## Install

Recommended install:

```sh
cp -R "dist/Logi Fine Volume Hotkeys.app" "$HOME/Applications/"
mkdir -p "$HOME/Library/LaunchAgents"
cp "dist/com.murat-taskaynatan.logi-fine-volume.hotkeys.plist" "$HOME/Library/LaunchAgents/"
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.murat-taskaynatan.logi-fine-volume.hotkeys.plist"
launchctl kickstart -k "gui/$(id -u)/com.murat-taskaynatan.logi-fine-volume.hotkeys"
```

Optional fallback:

```sh
cp -R "dist/Logi Fine Volume Down.app" "$HOME/Applications/"
cp -R "dist/Logi Fine Volume Up.app" "$HOME/Applications/"
```

The fallback app-launch path still exists for manual testing, but the hotkey helper is the recommended setup because it avoids the Logi Smart Actions instability where both buttons can collapse onto the same app after some uptime.

## Configure Logi Options+

1. Open Logi Options+.
2. Select your Logitech keyboard.
3. Reassign the `Volume Down` key.
4. Choose `Keystroke Assignment`.
5. Record `Control + Option + Command + J`.
6. Reassign the `Volume Up` key.
7. Record `Control + Option + Command + K`.

The hotkey helper listens for those shortcuts globally and adjusts volume in exact steps.

If you still want the old app-launch path, assign the down and up apps directly instead, but it is less reliable over time.

## Change the step size

Edit `STEP_SIZE` in:

- `scripts/build_apps.sh`

Then rebuild the apps:

```sh
./scripts/build_apps.sh
```

## Verify

After assigning the hotkeys in Logi Options+:

- press `Volume Down` once and confirm the volume decreases by the configured step
- press `Volume Up` once and confirm the volume increases by the configured step
- confirm there is no repeated beep from an unhandled shortcut
- confirm a small custom volume HUD appears

## Troubleshooting

- If the hotkeys beep, the background helper is not running. Reload the LaunchAgent and confirm `Logi Fine Volume Hotkeys.app` is running.
- If the volume still behaves like the normal large macOS step, make sure the MX Keys buttons are assigned to the keystrokes above rather than the default media action.
- If nothing happens, launch `Logi Fine Volume Hotkeys.app` manually once from `~/Applications` and try again.
- If you changed `STEP_SIZE`, rebuild and reinstall the generated app and LaunchAgent plist.

## Step-by-step guide

See [INSTRUCTIONS.md](INSTRUCTIONS.md) for a shorter setup walkthrough.
