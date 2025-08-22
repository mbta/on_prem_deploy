#!/usr/bin/env bash

set -e

scripts=$(dirname $0)

cat <<EOF
#cloud-config
---
$(bash "$scripts/build_user_data.sh")

# Remove userdata from VMware
redact:
  - userdata
EOF
