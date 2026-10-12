# Run ONCE inside Termux:  sh /sdcard/Download/fold6/setup-termux.sh
# Copies the Shizuku rish dex + boot script into Termux's private storage and tests access.
SRC=/sdcard/Download/fold6
mkdir -p ~/.rish ~/.termux/boot
rm -f ~/.rish/rish_shizuku.dex
cp $SRC/rish_shizuku.dex ~/.rish/ && chmod 400 ~/.rish/rish_shizuku.dex
cp $SRC/termux-boot-coverlock ~/.termux/boot/coverlock && chmod 700 ~/.termux/boot/coverlock
echo "Installed. Testing Shizuku (tap ALLOW if a prompt appears)..."
RISH_APPLICATION_ID=com.termux /system/bin/app_process \
  -Djava.class.path=$HOME/.rish/rish_shizuku.dex /system/bin \
  --nice-name=rish rikka.shizuku.shell.ShizukuShellLoader -c id
