#!/usr/bin/env bash
set -euo pipefail
SLOT="$1"
SLOT_BASE="/var/lib/proofrun"
IMG="$SLOT_BASE/slot-${SLOT}.img"
MNT="$SLOT_BASE/slots/${SLOT}"
if mountpoint -q "$MNT"; then
    umount -f "$MNT" || umount -l "$MNT"
fi
mkfs.ext4 -F -q "$IMG"
mount -o loop,nodev,nosuid "$IMG" "$MNT"
chown -R 10001:10001 "$MNT"
echo "Slot $SLOT reset."
