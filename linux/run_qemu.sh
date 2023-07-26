#!/usr/bin/env bash
# Run the Linux VM via QEMU
# $ bash run_qemu.sh [hostname]

set -e
ISO_PATH=ubuntu-22.04-server-cloudimg-amd64.img
ISO_URL=https://cloud-images.ubuntu.com/releases/jammy/release/"$ISO_PATH"

if [ "$(arch)" = "arm64" ]; then
   QEMU_CPU=max
   QEMU_MACHINE=q35
else
   QEMU_CPU=host
   QEMU_MACHINE="accel=hvf"
fi

HOSTNAME=${1:-qemu}
tmpdir=tmp # ignored by .gitignore
mkdir -p "$tmpdir"

if [ -f "$tmpdir"/boot-disk.img ]; then
   echo Boot disk exists, not rebuilding...
else
   pushd "$tmpdir" >/dev/null
   wget -N "$ISO_URL"

   cp $ISO_PATH boot-disk.img
   qemu-img resize boot-disk.img +8G
   popd >/dev/null
fi

bash build_cidata_iso.sh "$HOSTNAME"

qemu-system-x86_64 \
	 -net 'nic,model=virtio-net-pci' \
	 -net 'user,hostfwd=tcp::5555-:22' \
	 -machine $QEMU_MACHINE \
	 -cpu $QEMU_CPU \
	 -smp 2 \
	 -m 1024 \
	 -nographic \
	 -hda "$tmpdir"/boot-disk.img \
	 -cdrom "$tmpdir"/"$HOSTNAME".iso
