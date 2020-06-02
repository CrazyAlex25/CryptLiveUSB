#!/bin/sh
. /scripts/functions
PREREQ=""
prereqs()
{
echo "$PREREQ"
}
case $1 in 
prereqs)
	prereqs
	exit 0
	;;
esac

mkdir -p /iso
for name in `blkid -o device`
do
	log_warning_msg "Test mount $name to /iso"
	mount_opt=
	fs_type=`blkid -s TYPE -o value $name`
	if [ "$fs_type" = "iso9660" ]; then
		mount_opt="-t iso9660"
	fi
	mount $mount_opt $name /iso
	if [ $? -eq 0 ]; then
		break
	fi
done
loop=`losetup -f`
#loop=/dev/loop1
log_warning_msg "Loop device $loop"
losetup $loop /iso/live/crypt.img
echo "target=disk,source=$loop,key=none" > /conf/conf.d/cryptroot

