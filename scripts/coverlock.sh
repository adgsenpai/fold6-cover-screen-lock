#!/system/bin/sh
# coverlock.sh - keep a Galaxy Z Fold on its cover screen (for a dead inner display).
# Runs as the adb "shell" user (via adb or Shizuku/rish).
#
# Forces the device_state to CLOSED (0). Samsung's FlexibleDeviceStatePolicy cancels
# that override every time the hinge reports "closed", so we watch the lid switch and
# re-apply it, with a slow poll as a safety net.

apply()  { cmd device_state state 0 >/dev/null 2>&1; }
active() { dumpsys device_state | grep -q "Override Request active: true"; }

# Find the input device that reports SW_LID (named "flip" on the Fold6).
LID_DEV=$(getevent -pl 2>/dev/null | awk '/^add device/{dev=$4} /SW_LID/{print dev; exit}')

apply

if [ -n "$LID_DEV" ]; then
  ( getevent -l "$LID_DEV" | while read -r _ type code val; do
      [ "$code" = "SW_LID" ] && { sleep 0.3; apply; }
    done ) &
fi

while true; do active || apply; sleep 2; done
