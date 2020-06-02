rm -rf image
mkdir -p image/live
mkdir -p image/isolinux
mksquashfs rootfs image/live/filesystem.squashfs  -e tmp/* sys/* srv/* run/* root/* proc/* opt/* mnt/* media/* home/* boot
