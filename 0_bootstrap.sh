#!/bin/bash
passwd="mysecretpass"

rm -rf rootfs
arch="amd64"
hostname="live"
mirror="http://ru.archive.ubuntu.com/ubuntu/"
suite="bionic"
variant="minbase"
components="main,universe,restricted,multiverse"

base_sys="linux-image-4.15.0-20-generic, linux-modules-extra-4.15.0-20-generic, linux-firmware, dropbear, cryptsetup, systemd-sysv, nano, net-tools, ifupdown, psmisc, procps, locales, intel-microcode, amd64-microcode, dbus-user-session"
extra_sys=""
include="$base_sys $extra_sys"

debootstrap --merged-usr --cache-dir=`(pwd)`/cache --arch="$arch" --include="$include" --components="$components" --variant="$variant" "$suite"  rootfs "$mirror"
echo "Setting hostname..."
echo "$hostname" > rootfs/etc/hostname

lang="en_US.UTF-8"
echo "Setting LANG $lang"
chroot rootfs /bin/bash -c "locale-gen $lang && update-locale LANG=$lang"

echo "Setting root passwd"
chroot rootfs /bin/bash -c "echo -e '$passwd\n$passwd\n' | passwd root"

echo "Allow password in ssh"
sed -i 's/local flags=\"Fs\"/local flags=\"F\"/' rootfs/usr/share/initramfs-tools/scripts/init-premount/dropbear

echo "Add scripts & hooks"
echo "overlay
r8169
r8152
usbnet
" >> rootfs/etc/initramfs-tools/modules

chmod +x scripts/*.sh
cp scripts/00_passwd_hook.sh rootfs/etc/initramfs-tools/hooks/
cp scripts/00_fix_busybox.sh rootfs/etc/initramfs-tools/hooks/

cp scripts/00_luks.sh rootfs/etc/initramfs-tools/scripts/init-premount/
cp scripts/00_overlay.sh rootfs/etc/initramfs-tools/scripts/local-premount/
cp scripts/00_network.sh rootfs/etc/initramfs-tools/scripts/local-bottom/

echo "Add CRYPTSETUP"
echo "CRYPTSETUP=y" >> rootfs/etc/cryptsetup-initramfs/conf-hook

chroot rootfs /bin/bash -c "update-initramfs -u"

cp scripts/cryptroot-unlock rootfs/bin/

rm -rf rootfs/tmp/*
rm -rf rootfs/var/cache/apt/*


