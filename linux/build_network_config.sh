#!/usr/bin/env sh

set -e

IP_ADDRESS=${1:-}

if [ -z "$IP_ADDRESS" ]; then
cat <<EOF
network:
  version: 2
  ethernets:
    zero:
      match:
        name: en*
      dhcp4: true
EOF
else
cat <<EOF
network:
  version: 2
  ethernets:
    zero:
      match:
        name: en*
      dhcp4: false
      addresses: ["${IP_ADDRESS}/24"]
      nameservers:
        addresses: ["10.108.46.214", "10.108.46.215"]
      routes:
        - to: "0.0.0.0/0"
          via: "10.108.45.1"
EOF
fi
