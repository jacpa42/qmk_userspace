#!/usr/bin/env bash

MOUNT_POINT="/mnt/usb"
DEVICE="/dev/sda1"
firmware="/home/jacob/Downloads/bastardkb_charybdis_3x5_custom.uf2"
[[ -f "$firmware" ]] || {
    echo "no firware file found at $firmware"
    exit 1
}
echo "using firmware file: $firmware"

echo "Watching for $DEVICE..."

while true; do
    # Wait until the device appears
    until [ -b "$DEVICE" ]; do
        sleep 1
    done

    echo "$DEVICE detected, mounting..."
    sudo mount "$DEVICE" "$MOUNT_POINT" || {
        echo "Mount failed"
        sleep 2
        continue
    }

    echo "Copying file..."
    cp "$firmware" "$MOUNT_POINT"/ || echo "Copy failed"

    sync
    ls -A "$MOUNT_POINT"
    echo "Waiting for device removal..."

    sleep 2

    while [ "$(ls -A "$MOUNT_POINT" 2>/dev/null | wc -l)" -ne 0 ]; do
        echo "Device has not rebooted yet..."
        sleep 1
    done

    echo "Device rebooted, unmounting..."
    sudo umount "$MOUNT_POINT" 2>/dev/null || true

    echo "Cycle complete, waiting for next insertion..."
    sleep 1
done
