rm live.iso
#echo "UI menu.c32
echo "
UI menu.c32
prompt 0
timeout 20
DEFAULT Custom
MENU TITLE Boot Menu

label Custom
menu label ^Custom
menu default
kernel /live/vmlinuz
append initrd=/live/initrd ipv6.disable=1 net.ifnames=0 biosdevname=0 ip=192.168.0.192::192.168.0.1:255.255.255.0::eth0:none" > image/isolinux/isolinux.cfg

cp rootfs/boot/vmlinuz* image/live/vmlinuz
cp rootfs/boot/initrd* image/live/initrd
cp /usr/lib/ISOLINUX/isolinux.bin image/isolinux/
cp /usr/lib/syslinux/modules/bios/menu.c32  image/isolinux/
cp /usr/lib/syslinux/modules/bios/ldlinux.c32  image/isolinux/
cp /usr/lib/syslinux/modules/bios/libutil.c32  image/isolinux/
cp interfaces image/interfaces
# -r -J -joliet-long
xorriso -as mkisofs -r -J -joliet-long -l -cache-inodes \
-isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin -partition_offset 16 \
-A "ISO"  \
-b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table \
-o live.iso image
