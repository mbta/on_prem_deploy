#!/usr/bin/env bash
# Modify an ubuntu install image and add an autoinstall configuration

set -e

[[ -f $1 ]] || { echo "specify ubuntu iso file"; exit 1; }

mkdir -p tmp
cat > tmp/autoinstall.yaml <<EOF
$(< cloud-init/autoinstall.yaml)
user-data:
$(bash build_user_data.sh | sed "s/^/  /g")
EOF

xorriso -indev "$1" -outdev tmp/output.iso -blank as_needed -map tmp/autoinstall.yaml /autoinstall.yaml -boot_image any replay
