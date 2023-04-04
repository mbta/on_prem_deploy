#!/bin/bash
UBUNTU_VERSION=22.04
UBUNTU_ARCH=amd64
UBUNTU_SHA256=345fbbb6ec827ca02ec1a1ced90f7d40d3fd345811ba97c5772ac40e951458e1

DISK_IMAGE=ubuntu-$UBUNTU_VERSION-server-cloudimg-$UBUNTU_ARCH.img
IMAGE_URL=https://cloud-images.ubuntu.com/releases/$UBUNTU_VERSION/release/$DISK_IMAGE

curl -C - -o $DISK_IMAGE $IMAGE_URL
if ! echo "$UBUNTU_SHA256  $DISK_IMAGE" | sha256sum -c -; then
    exit 1
fi
cp $DISK_IMAGE image.img
qemu-img resize image.img +2G
qemu-system-x86_64 -net nic -net 'user,hostfwd=tcp::5555-:22' -machine accel=hvf:tcg \
    -cpu host -m 512 -nographic -hda image.img \
    -smbios type=1,serial=ds='nocloud-net;s=http://10.0.2.2:8000/'
