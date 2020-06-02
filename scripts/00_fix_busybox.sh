#!/bin/sh

# UPDATE: You most likely do not need this workaround anymore.
# The bug has been fixed in cryptsetup 2:2.0.2-1ubuntu1.1

# This hook is for fixing busybox-initramfs issue while unlocking a luks
# encrypted rootfs. The problem is that the included busybox version
# is stripped down to the point that it breaks cryptroot-unlock script:
# https://bugs.launchpad.net/ubuntu/+source/busybox/+bug/1651818

# This is a non-aggressive fix based on the original busybox-initramfs hook
# until the bug is fixed.
# busybox or busybox-static package must be present for this to work

# This file should be placed in /etc/initramfs-tools/hooks/ and have +x flag set
# after that you need to rebuild the initramfs with 'update-initramfs -u'

# Users reported the solution working on at least:
# Ubuntu 17.04, 17.10, 18.04

# Also note that this does not replace busybox-initramfs package.
# The package must be present, this hook just fixes what's broken.

# Hamy - www.hamy.io

set -e

case "${1:-}" in
  prereqs)  echo ""; exit 0;;
esac

[ n = "$BUSYBOX" ] && exit 0

[ -r /usr/share/initramfs-tools/hook-functions ] || exit 0
. /usr/share/initramfs-tools/hook-functions

# Testing the presence of busybox-initramfs hook
[ -x /usr/share/initramfs-tools/hooks/zz-busybox-initramfs ] || exit 0

# The original busybox binary added by busybox-initramfs
BB_BIN_ORG=$DESTDIR/bin/busybox
[ -x $BB_BIN_ORG ] || exit 0

# The one we want to replace it with
[ -x /bin/busybox ] || exit 0
BB_BIN=/bin/busybox

# Ensure the bug still exists
if ! `grep --silent --no-messages 'ps -eo' /usr/share/cryptsetup/initramfs/bin/cryptroot-unlock >/dev/null`; then
  echo "WARNING: busybox-initramfs workaround is no longer needed. Please remove it and rebuild initramfs"
  exit 0
fi

# Ensure the original busybox lacks extended options
# and the soon-to-be-replaced-by one does not
if $BB_BIN_ORG ps -eo pid,args >/dev/null 2>&1; then
  exit 0
elif ! $BB_BIN ps -eo pid,args >/dev/null 2>&1; then
  exit 0
fi

# Get the inode number of busybox-initramfs binary
BB_BIN_ORG_IND=$(stat --format=%i $BB_BIN_ORG)

# Replace the binary
rm -f $BB_BIN_ORG
copy_exec $BB_BIN /bin/busybox

echo -n "Fixing busybox-initramfs for:"

for alias in $($BB_BIN --list-long); do
  alias="${alias#/}"
  case "$alias" in
    # strip leading /usr, we don't use it
    usr/*) alias="${alias#usr/}" ;;
    */*) ;;
    *) alias="bin/$alias" ;;  # make it into /bin
  esac

  # Remove (and then re-add) all the hardlinks added by busybox-initramfs
  if [ -e "$DESTDIR/$alias" ] && [ $(stat --format=%i "$DESTDIR/$alias") -eq $BB_BIN_ORG_IND ]; then
      echo -n " ${alias##*/}"
      rm -f "$DESTDIR/$alias"
      ln "$DESTDIR/bin/busybox" "$DESTDIR/$alias"
  fi
done

# To get a trailing new line
echo