# Instructions

## Quick setup

1. Build the helper apps:

```sh
./scripts/build_apps.sh
```

2. Install the hotkey helper:

```sh
cp -R "dist/Logi Fine Volume Hotkeys.app" "$HOME/Applications/"
mkdir -p "$HOME/Library/LaunchAgents"
cp "dist/com.murat-taskaynatan.logi-fine-volume.hotkeys.plist" "$HOME/Library/LaunchAgents/"
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.murat-taskaynatan.logi-fine-volume.hotkeys.plist"
launchctl kickstart -k "gui/$(id -u)/com.murat-taskaynatan.logi-fine-volume.hotkeys"
```

3. Open Logi Options+.
4. Select your Logitech keyboard.
5. Change the `Volume Down` button action to `Keystroke Assignment`.
6. Record `Control + Option + Command + J`.
7. Change the `Volume Up` button action to `Keystroke Assignment`.
8. Record `Control + Option + Command + K`.

## What the helper does

- `Control + Option + Command + J` lowers output volume by the configured step
- `Control + Option + Command + K` raises output volume by the configured step
- volume is clamped between `0` and `100`
- the helper unmutes output when adjusting volume
- the helper shows a small custom volume HUD because the built-in macOS media overlay is not available through this workaround
- the helper runs at login through a user LaunchAgent

## Change the amount

Edit:

- [build_apps.sh](scripts/build_apps.sh)

Change `STEP_SIZE`.

Then rebuild:

```sh
./scripts/build_apps.sh
```

## Troubleshooting

- If a key beeps, the hotkey helper is not running or the button is assigned to the wrong keystroke.
- If the volume changes by the normal large step, the key is still mapped to Logitech's default media control.
- If nothing happens, open `~/Applications/Logi Fine Volume Hotkeys.app` manually once and try again.
- If you change `STEP_SIZE`, rebuild and reinstall both the app and the LaunchAgent plist.
