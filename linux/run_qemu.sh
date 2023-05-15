#!/usr/bin/env bash
# Run the Linux VM via QEMU
# $ bash run_qemu.sh [hostname]

set -e
ISO_URL=https://cloud-images.ubuntu.com/minimal/releases/jammy/release/ubuntu-22.04-minimal-cloudimg-amd64.img
ISO_PATH=ubuntu-minimal-amd64.img
if [ $(arch) = "arm64" ]; then
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
mkdir -p $tmpdir
curl -C - -o $tmpdir/$ISO_PATH "$ISO_URL"
mkdir -p $tmpdir/config

cat > $tmpdir/config/meta-data <<-EOF
local-hostname: $HOSTNAME
EOF

cat cloud-init/user-data \
| sed "s/GITHUB_REPO/${GITHUB_REPO/\//\\/}/g" \
| sed "s/GIT_BRANCH/$GIT_BRANCH/g" \
| sed "s/ANSIBLE_VAULT_PASSWORD/$ANSIBLE_VAULT_PASSWORD/g" \
> $tmpdir/config/user-data

echo > $tmpdir/config/vendor-data

rm -f $tmpdir/seed.iso
hdiutil makehybrid -o $tmpdir/seed.iso -hfs -joliet -iso -default-volume-name cidata $tmpdir/config/
rm -r $tmpdir/config

cp $tmpdir/$ISO_PATH $tmpdir/boot-disk.img
qemu-img resize $tmpdir/boot-disk.img +4G

qemu-system-x86_64 \
	 -net 'nic,model=virtio-net-pci' \
	 -net 'user,hostfwd=tcp::5555-:22' \
	 -machine $QEMU_MACHINE \
	 -cpu $QEMU_CPU \
	 -m 1024 \
	 -nographic \
	 -hda $tmpdir/boot-disk.img \
	 -cdrom $tmpdir/seed.iso