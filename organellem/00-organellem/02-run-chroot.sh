#!/bin/bash -ex

# autologin
systemctl set-default multi-user.target
ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin "$FIRST_USER_NAME" --noclear %I linux
EOF

# compile new dt overlay for spi
dtc -@ -I dts -O dtb -o /boot/overlays/wm8731-spi.dtbo /boot/audioinjector-wm8731-audio-spi-overlay.dts

# disable systemd services
systemctl disable apt-daily.service
systemctl disable dhcpcd.service
systemctl disable dnsmasq.service
systemctl disable dphys-swapfile.service
systemctl disable hciuart.service
systemctl disable hostapd.service
systemctl disable keyboard-setup.service
systemctl disable systemd-timesyncd.service
systemctl disable triggerhappy.service
systemctl disable vncserver-x11-serviced.service
systemctl disable wpa_supplicant.service
systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket
systemctl mask cups.service
systemctl mask cups.socket
systemctl mask cups.path
systemctl mask cups-browsed.service

# spool
rm -rf /var/spool
ln -s /tmp /var/spool
sed -i 's/spool 0755/spool 1777/' /usr/lib/tmpfiles.d/var.conf

# resolv.conf
touch /tmp/dhcpcd.resolv.conf
rm -f /etc/resolv.conf
ln -s /tmp/dhcpcd.resolv.conf /etc/resolv.conf

# Organelle OS
cd "/home/$FIRST_USER_NAME/Organelle_OS"
make organelle_m_deploy
