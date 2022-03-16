#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# go to project root
cd ..

for file in $(yq e ".generated[]" apigen.lock); do
    if [ -f "$file" ]; then
        rm "$file"

        # delete directory if empty
        parent_dir="$(dirname "$file")"
        if [ -z "$(ls -A "$parent_dir")" ]; then
           rm -r "$parent_dir"

           # check all parent dirs all the way to project root
           parent_dir="$(dirname "$parent_dir")"
           while [[ $parent_dir != "." ]]; do
               if [ -z "$(ls -A "$parent_dir")" ]; then
                   rm -r "$parent_dir"
               fi
               parent_dir="$(dirname "$parent_dir")"
           done
        fi
    fi
done
