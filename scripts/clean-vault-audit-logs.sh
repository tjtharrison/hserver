#!/bin/bash

# Fail on error
set -e

for file in $(find /mnt/nfs/vault-audit-vault-* -name "audit.log"); do
    echo "Cleaning $file.."
    sudo truncate -s 0 $file
    echo "Cleaned $file"
done