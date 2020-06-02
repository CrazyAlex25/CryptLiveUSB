#!/bin/sh
prereqs()
{
echo ""
}
case $1 in 
    prereqs)
	prereqs
	exit 0
    ;;
esac

mkdir /run/lower
mkdir /run/upper
mkdir /run/work
mount /dev/mapper/disk /run/lower
mount -t overlay -o lowerdir=/run/lower,upperdir=/run/upper,workdir=/run/work none /root
