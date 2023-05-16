#!/usr/bin/env bash
# Run the Linux VM via QEMU
# $ bash run_qemu.sh [hostname]

set -e
ISO_URL=https://cloud-images.ubuntu.com/minimal/releases/jammy/release/ubuntu-22.04-minimal-cloudimg-amd64.img
ISO_PATH=ubuntu-minimal-amd64.img
if [ "$(arch)" = "arm64" ]; then
   QEMU_CPU=max
   QEMU_MACHINE=q35
else
   QEMU_CPU=host
   QEMU_MACHINE="accel=hvf"
fi

HOSTNAME=${1:-qemu}
GITHUB_REPO=${GITHUB_REPO:-mbta/on_prem_deploy}
GIT_BRANCH=${GIT_BRANCH:-linux}
if [ -z "${ANSIBLE_VAULT_PASSWORD+x}" ]; then
  ANSIBLE_VAULT_PASSWORD=$(cat .ansible_vault_password)
fi
tmpdir=tmp # ignored by .gitignore
mkdir -p "$tmpdir"

if [ -f "$tmpdir"/boot-disk.img ]; then
   echo Boot disk exists, not rebuilding...
else
   curl -C - -o "$tmpdir"/$ISO_PATH "$ISO_URL"

   cp "$tmpdir"/$ISO_PATH "$tmpdir"/boot-disk.img
   qemu-img resize "$tmpdir"/boot-disk.img +4G
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
