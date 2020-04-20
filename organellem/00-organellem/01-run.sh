#!/bin/bash -ex

CONFIGTXT="${ROOTFS_DIR}/boot/config.txt"
CMDLINETXT="${ROOTFS_DIR}/boot/cmdline.txt"
FSTAB="${ROOTFS_DIR}/etc/fstab"
LIMITSCONF="${ROOTFS_DIR}/etc/security/limits.conf"
SYSTEMCONF="${ROOTFS_DIR}/etc/systemd/system.conf"

function append {
    grep -Fxq "$1" "$2" || echo "$1" >> "$2" # append line $1 to file $2 if not already present
}

function append_cmdline {
    grep -Fq "$1" "$CMDLINETXT" || sed -i "$ s/$/ $1/" "$CMDLINETXT" # append $1 to cmdline.txt if not already present
}

# overwrite resize2fs_once to create /sdcard partition on first boot
install -m 755 files/resize2fs_once "${ROOTFS_DIR}/etc/init.d/"

# setup WM8731 audio driver with SPI control
install -m 755 files/audioinjector-wm8731-audio-spi-overlay.dts "${ROOTFS_DIR}/boot/"
sh files/fixit.sh "${ROOTFS_DIR}/lib/modules/*-v7+/kernel/sound/soc/bcm/snd-soc-audioinjector-pi-soundcard.ko"

# default ALSA mixer settings
install -m 755 files/asound.state "${ROOTFS_DIR}/var/lib/alsa/"

# config.txt
append 'boot_delay=0' "$CONFIGTXT"
append 'disable_splash=1' "$CONFIGTXT"
append 'dtoverlay=gpio-poweroff,gpiopin=12,active_low=1' "$CONFIGTXT"
append 'dtoverlay=midi-uart0' "$CONFIGTXT"
append 'dtoverlay=pi3-act-led,gpio=24,activelow=on' "$CONFIGTXT"
append 'dtoverlay=pi3-miniuart-bt' "$CONFIGTXT"
append 'dtoverlay=wm8731-spi' "$CONFIGTXT"
append 'enable_uart=1' "$CONFIGTXT"
append 'gpu_mem=64' "$CONFIGTXT"
sed -i 's/^#disable_overscan=1/disable_overscan=1/' "$CONFIGTXT"
sed -i 's/^dtparam=audio=on/#dtparam=audio=on/' "$CONFIGTXT"
sed -i 's/^#dtparam=i2c_arm=on/dtparam=i2c_arm=on/' "$CONFIGTXT"
sed -i 's/^#dtparam=spi=on/dtparam=spi=on/' "$CONFIGTXT"
sed -i 's/^#hdmi_force_hotplug=1/hdmi_force_hotplug=1/' "$CONFIGTXT"

# cmdline.txt
append_cmdline 'audit=0'
append_cmdline 'fastboot'
append_cmdline 'noswap'
append_cmdline 'plymouth.enable=0'
append_cmdline 'quiet'
append_cmdline 'ro'
append_cmdline 'selinux=0'
sed -i 's/console=serial0,[0-9]\+ //' "${ROOTFS_DIR}/boot/cmdline.txt"
sed -i 's| init=/usr/lib/raspi-config/init_resize.sh||' "${ROOTFS_DIR}/boot/cmdline.txt"
sed -i 's/fsck.repair=yes/fsck.mode=skip/' "${ROOTFS_DIR}/boot/cmdline.txt"

# enable I2C
grep -Fxq "i2c-dev" "${ROOTFS_DIR}/etc/modules" || echo "i2c-dev" >> "${ROOTFS_DIR}/etc/modules"

# no password sudo
echo "$FIRST_USER_NAME ALL=(ALL) NOPASSWD: ALL" > "${ROOTFS_DIR}/etc/sudoers.d/010_$FIRST_USER_NAME-nopasswd"
chmod 0440 "${ROOTFS_DIR}/etc/sudoers.d/010_$FIRST_USER_NAME-nopasswd"

# user directories
mkdir -p "${ROOTFS_DIR}/sdcard"
mkdir -p "${ROOTFS_DIR}/usbdrive"

# fstab
append '/dev/mmcblk0p3 /sdcard ext4 defaults,noatime,nofail,x-systemd.device-timeout=5s 0 0' "$FSTAB"
append 'tmpfs /var/log tmpfs nodev,nosuid 0 0' "$FSTAB"
append 'tmpfs /var/tmp tmpfs nodev,nosuid 0 0' "$FSTAB"
append 'tmpfs /tmp tmpfs nodev,nosuid 0 0' "$FSTAB"

# limits.conf
append "@$FIRST_USER_NAME - rtprio 99" "$LIMITSCONF"
append "@$FIRST_USER_NAME - memlock unlimited" "$LIMITSCONF"
append "@$FIRST_USER_NAME - nice -10" "$LIMITSCONF"

# system.conf
append 'DefaultTimeoutStartSec=10s' "$SYSTEMCONF"
append 'DefaultTimeoutStopSec=5s' "$SYSTEMCONF"

# organelle OS
rm -rf "${ROOTFS_DIR}/home/$FIRST_USER_NAME/Organelle_OS"
git clone https://github.com/critterandguitari/Organelle_OS.git "${ROOTFS_DIR}/home/$FIRST_USER_NAME/Organelle_OS"

# patches
rm -rf "${ROOTFS_DIR}/usbdrive/Patches"
git clone https://github.com/critterandguitari/Organelle_Patches.git "${ROOTFS_DIR}/usbdrive/Patches"
rm -f "${ROOTFS_DIR}/usbdrive/Patches/README.md"
rm -f "${ROOTFS_DIR}/usbdrive/Patches/.gitignore"
rm -rf "${ROOTFS_DIR}/usbdrive/Patches/.git"

# self test
rm -rf "${ROOTFS_DIR}/usbdrive/Organelle_Test_Patches"
git clone https://github.com/critterandguitari/Organelle_Test_Patches.git "${ROOTFS_DIR}/usbdrive/Organelle_Test_Patches" &&
mv "${ROOTFS_DIR}/usbdrive/Organelle_Test_Patches/Test M" "${ROOTFS_DIR}/usbdrive/Patches/Utilities"
rm -rf "${ROOTFS_DIR}/usbdrive/Organelle_Test_Patches"
