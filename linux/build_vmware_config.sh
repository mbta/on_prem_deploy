#!/usr/bin/env bash
# Creates the setup script for a VMware VM
# $ bash build_vmware_config.sh <hostname>

set -e
HOSTNAME=$1
GITHUB_REPO=${GITHUB_REPO:-mbta/on_prem_deploy}
GIT_BRANCH=${GITHUB_REPO:-linux}
if [ -z "${ANSIBLE_VAULT_PASSWORD+x}" ]; then
  ANSIBLE_VAULT_PASSWORD=$(cat .ansible_vault_password)
fi

tmpdir=$(mktemp -d)

echo "govc vm.change -vm \"PATH_TO_THE_VM\" \\"
cat > $tmpdir/meta-data <<-EOF
local-hostname: $HOSTNAME
EOF
echo "-e guestinfo.metadata=\"$(gzip -c9 < $tmpdir/meta-data | base64)\" \\"
echo "-e guestinfo.metadata.encoding=\"gzip+base64\" \\"

cat cloud-init/user-data \
| sed "s/GITHUB_REPO/${GITHUB_REPO/\//\\/}/g" \
| sed "s/GIT_BRANCH/$GIT_BRANCH/g" \
| sed "s/ANSIBLE_VAULT_PASSWORD/$ANSIBLE_VAULT_PASSWORD/g" \
> $tmpdir/user-data

echo "-e guestinfo.userdata=\"$(gzip -c9 < $tmpdir/user-data | base64)\" \\"
echo "-e guestinfo.userdatadata.encoding=\"gzip+base64\""
rm -r $tmpdir
