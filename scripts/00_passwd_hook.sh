#!/bin/sh

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

grep -e root /etc/shadow > ${DESTDIR}/etc/shadow
