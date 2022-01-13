#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# go to project root
cd ..

for file in $(yq e ".generated[]" apigen.lock); do
    if [ -f "$file" ]; then
        rm "$file"
    fi
done
