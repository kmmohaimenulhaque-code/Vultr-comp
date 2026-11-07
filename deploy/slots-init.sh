#!/usr/bin/env bash
set -euo pipefail
SLOT_BASE="/var/lib/proofrun"
mkdir -p "$SLOT_BASE/slots"
for i in {0..3}; do
    IMG="$SLOT_BASE/slot-${i}.img"
    MNT="$SLOT_BASE/slots/${i}"
    mkdir -p "$MNT"
    if [ ! -f "$IMG" ]; then
        truncate -s 4G "$IMG"
        mkfs.ext4 -F -q "$IMG"
    fi
    if ! mountpoint -q "$MNT"; then
        mount -o loop,nodev,nosuid "$IMG" "$MNT"
    fi
    chown -R 10001:10001 "$MNT"
done
echo "Slots initialized."
