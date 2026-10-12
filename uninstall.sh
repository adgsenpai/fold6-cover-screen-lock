#!/bin/bash
# uninstall.sh - stop the watcher and give control back to the hinge sensor.
adb shell 'pkill -f "^sh /data/local/tmp/coverlock[.]sh"; pkill -f "^getevent -l /dev/input"; cmd device_state state reset; rm -f /data/local/tmp/coverlock.sh; rm -rf /sdcard/Download/fold6'
echo "Watcher stopped. In Termux also run:  rm ~/.termux/boot/coverlock"
