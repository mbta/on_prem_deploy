#!/usr/bin/env bash

set -e

scripts=$(dirname $0)
root=$(dirname $scripts)

GITHUB_REPO=${GITHUB_REPO:-mbta/on_prem_deploy}
GIT_BRANCH=${GIT_BRANCH:-main}
if [ -z "${ANSIBLE_VAULT_PASSWORD+x}" ]; then
  ANSIBLE_VAULT_PASSWORD=$(cat .ansible_vault_password)
fi

< "$root/cloud-init/user-data" \
sed "s/GITHUB_REPO/${GITHUB_REPO/\//\\/}/g" \
| sed "s/GIT_BRANCH/${GIT_BRANCH/\//\\/}/g" \
| sed "s/ANSIBLE_VAULT_PASSWORD/$ANSIBLE_VAULT_PASSWORD/g" \
