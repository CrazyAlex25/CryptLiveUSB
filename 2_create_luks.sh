passwd="mysecretpasswd2"

rm image/live/crypt.img
size=`du  --block-size=512 image/live/filesystem.squashfs |  awk '{print $1}'`
dd if=/dev/zero of=image/live/crypt.img bs=512 count=1 seek=$(($size+10320))
loopdev=`losetup -f`
losetup $loopdev image/live/crypt.img
echo -n $passwd |  cryptsetup -q luksFormat $loopdev -
echo -n $passwd |  cryptsetup -q luksOpen $loopdev crypt
dd if=image/live/filesystem.squashfs of=/dev/mapper/crypt bs=512
cryptsetup luksClose crypt
losetup -d $loopdev
rm image/live/filesystem.squashfs
