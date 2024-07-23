#!/usr/bin/env bash

set -e

cat <<EOF
#cloud-config
---
$(bash build_user_data.sh)

# Remove userdata from VMware
redact:
  - userdata
EOF
