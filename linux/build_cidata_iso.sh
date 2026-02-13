#!/usr/bin/env bash
# Build the CIDATA seed.iso
# $ bash build_cidata_iso.sh [hostname]

set -e

HOSTNAME=$1
tmpdir=tmp

mkdir -p "$tmpdir"/config
cat > "$tmpdir"/config/meta-data <<-EOF
local-hostname: $HOSTNAME
EOF

bash build_vm_user_data.sh | tee "$tmpdir"/config/user-data
bash build_network_config.sh > "$tmpdir"/config/network-config

echo

echo > "$tmpdir"/config/vendor-data

rm -f "$tmpdir"/"$HOSTNAME".iso
if [ -x "$(command -v hdiutil)" ]; then
  hdiutil makehybrid -o "$tmpdir"/"$HOSTNAME".iso -hfs -joliet -iso -default-volume-name cidata "$tmpdir"/config/
else
  xorriso -outdev "$tmpdir"/"$HOSTNAME".iso -volid cidata -blank as_needed -map "$tmpdir"/config /
fi
rm -r "$tmpdir"/config

echo Built "$tmpdir"/"$HOSTNAME".iso
