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

. /scripts/functions
log_warning_msg "Settings network interfaces"
cp /iso/interfaces /root/etc/network/interfaces