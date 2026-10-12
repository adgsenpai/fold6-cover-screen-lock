#!/bin/bash
# install.sh - run on your PC with the phone connected over USB debugging.
# Pushes the watcher, starts it immediately, and stages the Termux/Shizuku boot files.
set -e
cd "$(dirname "$0")"
adb wait-for-device

echo "[1/4] Pushing coverlock.sh"
adb push scripts/coverlock.sh /data/local/tmp/coverlock.sh >/dev/null
adb shell chmod 755 /data/local/tmp/coverlock.sh

echo "[2/4] Starting the watcher now"
adb shell 'pkill -f "^sh /data/local/tmp/coverlock[.]sh"; pkill -f "^getevent -l /dev/input"; true'
adb shell 'nohup setsid sh /data/local/tmp/coverlock.sh </dev/null >/dev/null 2>&1 &'
sleep 2
adb shell dumpsys device_state | grep -q "Override Request active: true" \
  && echo "      cover-screen lock ACTIVE" || echo "      WARNING: override not active"

echo "[3/4] Staging boot files in /sdcard/Download/fold6"
adb shell mkdir -p /sdcard/Download/fold6
adb push scripts/termux-boot-coverlock scripts/setup-termux.sh /sdcard/Download/fold6/ >/dev/null
if adb shell pm path moe.shizuku.privileged.api >/dev/null 2>&1; then
  TMP=$(mktemp -d)
  APK=$(adb shell pm path moe.shizuku.privileged.api | head -1 | sed 's/package://' | tr -d '\r')
  adb pull "$APK" "$TMP/shizuku.apk" >/dev/null
  unzip -o -q -j "$TMP/shizuku.apk" assets/rish_shizuku.dex -d "$TMP"
  adb push "$TMP/rish_shizuku.dex" /sdcard/Download/fold6/ >/dev/null
  rm -rf "$TMP"
  echo "      rish_shizuku.dex extracted from your installed Shizuku"
else
  echo "      Shizuku not installed yet - install it, then re-run this script for autostart"
fi

echo "[4/4] Permissions for Shizuku / Termux"
adb shell pm grant moe.shizuku.privileged.api android.permission.WRITE_SECURE_SETTINGS 2>/dev/null || true
adb shell appops set com.termux MANAGE_EXTERNAL_STORAGE allow 2>/dev/null || true
adb shell dumpsys deviceidle whitelist +com.termux +moe.shizuku.privileged.api >/dev/null 2>&1 || true

echo
echo "Done. For autostart after reboot, open Termux and run:"
echo "  sh /sdcard/Download/fold6/setup-termux.sh"
