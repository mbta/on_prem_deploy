#!/usr/bin/env bash
# Build the CIDATA seed.iso
# $ bash build_cidata_iso.sh [hostname]

set -e

HOSTNAME=$1
GITHUB_REPO=${GITHUB_REPO:-mbta/on_prem_deploy}
GIT_BRANCH=${GIT_BRANCH:-main}
if [ -z "${ANSIBLE_VAULT_PASSWORD+x}" ]; then
  ANSIBLE_VAULT_PASSWORD=$(cat .ansible_vault_password)
fi

tmpdir=tmp

mkdir -p "$tmpdir"/config
cat > "$tmpdir"/config/meta-data <<-EOF
local-hostname: $HOSTNAME
EOF

< cloud-init/user-data \
sed "s/GITHUB_REPO/${GITHUB_REPO/\//\\/}/g" \
| sed "s/GIT_BRANCH/$GIT_BRANCH/g" \
| sed "s/ANSIBLE_VAULT_PASSWORD/$ANSIBLE_VAULT_PASSWORD/g" \
| tee "$tmpdir"/config/user-data

echo

echo > "$tmpdir"/config/vendor-data

rm -f "$tmpdir"/"$HOSTNAME".iso
hdiutil makehybrid -o "$tmpdir"/"$HOSTNAME".iso -hfs -joliet -iso -default-volume-name cidata "$tmpdir"/config/
rm -r "$tmpdir"/config

echo Built "$tmpdir"/"$HOSTNAME".iso
