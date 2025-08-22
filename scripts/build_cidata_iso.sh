#!/usr/bin/env bash
# Build the CIDATA seed.iso
# $ bash build_cidata_iso.sh [hostname]

set -e

HOSTNAME=$1
scripts=$(dirname $0)
root=$(dirname $scripts)
tmpdir="$root"/tmp

mkdir -p "$tmpdir"/config
cat > "$tmpdir"/config/meta-data <<-EOF
local-hostname: $HOSTNAME
EOF

bash "$scripts"/build_vm_user_data.sh | tee "$tmpdir"/config/user-data
bash "$scripts"/build_network_config.sh > "$tmpdir"/config/network-config

echo

echo > "$tmpdir"/config/vendor-data

rm -f "$tmpdir"/"$HOSTNAME".iso
hdiutil makehybrid -o "$tmpdir"/"$HOSTNAME".iso -hfs -joliet -iso -default-volume-name cidata "$tmpdir"/config/
rm -r "$tmpdir"/config

echo Built "$tmpdir"/"$HOSTNAME".iso
