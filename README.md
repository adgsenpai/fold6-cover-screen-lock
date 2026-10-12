# Fold6 Cover-Screen Lock

Use a Samsung Galaxy Z Fold with a broken inner screen as a normal phone, running on the cover screen only.

My Fold6's inner (main) display broke and its cables were cut. Every time I unfolded the phone, Android switched to the inner screen. The cover screen turned off, the inner panel stayed black, and the phone was unusable while open.

This repo locks the phone to the **cover screen** whatever the hinge position, **without root**. The phone stays useful open or closed:

- 📸 Open it and stand it up as a **tripod or stand** to take photos or video with the cover screen
- 🎥 Prop it half-open on a desk for **video calls, recording or watching**
- 📱 Use it normally on the front screen without it going black when the hinge moves

Tested on a **Galaxy Z Fold6 (SM-F956B), Android 16 / One UI**. It should work on other Folds that expose the `device_state` service.

---

## How it works

Android has a `device_state` service that decides whether the phone is `CLOSED`, `HALF_OPENED`, `OPENED` and so on, and which screen to use for each. From adb you can override it:

```sh
adb shell cmd device_state state 0     # 0 = CLOSED -> cover screen
```

On its own this only lasts until you **close the phone once**. Samsung's `FlexibleDeviceStatePolicy` cancels the override whenever the lid switch reports "closed", and it's also gone after a reboot. So this repo adds:

| Piece | What it does |
|---|---|
| `scripts/coverlock.sh` | Runs on the phone as the `shell` user. Applies the override, watches the hinge (`SW_LID` input event) and reapplies it after every close, and checks every 2 s as a backup. |
| [Shizuku (thedjchi fork)](https://github.com/thedjchi/Shizuku) | Gives on-phone apps adb/shell rights. This fork can **start on boot over Wireless Debugging without root**; the official 13.6 can't. |
| Termux boot script | At boot, waits for Shizuku and then starts `coverlock.sh` through Shizuku's `rish` shell, so no PC is needed after a reboot. |

```
boot -> Shizuku (wireless debugging, auto) -> Termux boot script -> rish -> coverlock.sh
                                                                      |
                     hinge closes -> Samsung drops override -> coverlock re-applies CLOSED
```

---

## Quick start (PC + USB)

Requirements: `adb` on your PC, USB debugging enabled on the phone, and `unzip`.

```sh
git clone https://github.com/adgsenpai/fold6-cover-screen-lock
cd fold6-cover-screen-lock
./install.sh
```

The cover screen now stays on when you unfold. **This lasts until the next reboot.** For autostart, continue below.

## Autostart after reboot (no PC needed)

1. **Install Shizuku (thedjchi fork)** from its [releases](https://github.com/thedjchi/Shizuku/releases). If the official Shizuku is installed, uninstall it first because the signatures differ.
2. **Install Termux.** The Play Store build has boot scripts built in. With the F-Droid or GitHub build, also install Termux:Boot from the same source.
3. In Shizuku, choose **Start via Wireless debugging** and pair it once. Use **Settings > Developer options > Wireless debugging > Pair with pairing code**, then type the code into Shizuku's notification.
4. In Shizuku's settings, turn on **Start on boot**. The switch only appears after Shizuku has been started through Wireless Debugging.
5. Run `./install.sh` again on the PC. It extracts `rish_shizuku.dex` from your installed Shizuku and grants the needed permissions.
6. In Termux run:
   ```sh
   sh /sdcard/Download/fold6/setup-termux.sh
   ```
   Tap **Allow** on the Shizuku prompt. The output should end with `uid=2000(shell)`.
7. Reboot to test. About a minute after unlocking on Wi-Fi, the lock turns on by itself.

## Uninstall

```sh
./uninstall.sh
# then in Termux:
rm ~/.termux/boot/coverlock
```

---

## Gotchas I hit (so you don't have to)

- **The override is cancelled on every close.** That's why a watcher is needed, not a one-off command.
- **Input numbers change between reboots.** The hinge switch (`"flip"`) was `event3`, then `event4` after a reboot. `coverlock.sh` finds it by looking for `SW_LID`.
- **Apps can't read `/data/local/tmp`.** SELinux blocks it, so the Termux files are staged in `/sdcard/Download/fold6` and copied into Termux's private storage.
- **Play Store Termux won't exec `#!/system/bin/sh` scripts** ("unable to open /system/bin/sh"). Shizuku's `ShizukuShellLoader` is therefore called directly through `app_process`.
- **`pgrep -f` / `pkill -f` can match their own command line.** Anchored patterns like `^sh /data/local/tmp/coverlock[.]sh` avoid this.
- **Wi-Fi is needed at boot** for Shizuku's wireless-debugging start. Without Wi-Fi, connect within about 15 minutes of booting, or run `./install.sh` from a PC.
- Keep **battery optimization off** for Termux and Shizuku. `install.sh` adds both to the deviceidle whitelist.

## Disclaimer

This changes no system files and doesn't need root. Everything is reverted with `./uninstall.sh` or a reboot without autostart. Use at your own risk.

Written up on the blog: **https://adgstudios.co.za/blog/fold6-broken-inner-screen-cover-screen-only**

MIT © adgsenpai
