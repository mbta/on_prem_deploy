#!/usr/bin/env bash
# Run the Linux VM via QEMU
# $ bash run_qemu.sh [hostname]

set -e
ISO_NAME=ubuntu-22.04-server-cloudimg-amd64.img
ISO_URL=https://cloud-images.ubuntu.com/releases/jammy/release/"${ISO_NAME}"

ISO_DIR="iso" # ignored by .gitignore
mkdir -p "${ISO_DIR}"
ISO_PATH="${ISO_DIR}/${ISO_NAME}"


if [ "$(arch)" = "arm64" ]; then
   QEMU_CPU_TYPE="max"
   QEMU_MACHINE="q35"
elif [ "$(uname)" = "Darwin" ]; then
   QEMU_CPU_TYPE="host"
   QEMU_MACHINE="accel=hvf"
else
   QEMU_CPU_TYPE="host"
   QEMU_MACHINE="accel=kvm"
fi

QEMU_CPUS="${QEMU_CPUS:-2}"
QEMU_MEMORY="${QEMU_MEMORY:-1024}"

HOSTNAME=${1:-qemu}
tmpdir="tmp" # ignored by .gitignore
mkdir -p "${tmpdir}"

if [ -f "${tmpdir}/boot-disk.img" ]; then
   echo Boot disk exists, not rebuilding...
else
   if [ ! -f "${ISO_PATH}" ]; then
      echo "Could not find a cached OS image; downloading..."
      wget -N "${ISO_URL}" -O "${ISO_PATH}"
   fi
   cp "${ISO_PATH}" "${tmpdir}/boot-disk.img"

   pushd "${tmpdir}" >/dev/null
   qemu-img resize boot-disk.img +8G
   popd >/dev/null
fi

bash build_cidata_iso.sh "${HOSTNAME}"

qemu-system-x86_64 \
	 -net 'nic,model=virtio-net-pci' \
	 -net 'user,hostfwd=tcp::5555-:22' \
	 -machine "${QEMU_MACHINE}" \
	 -cpu "${QEMU_CPU_TYPE}" \
	 -smp "${QEMU_CPUS}" \
	 -m "${QEMU_MEMORY}" \
	 -nographic \
	 -hda "${tmpdir}/boot-disk.img" \
	 -cdrom "${tmpdir}/${HOSTNAME}.iso"
