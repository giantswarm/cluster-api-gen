#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

CRD_DIR="./$(dirname "$0")/../config/crd"
CRD_BASE_DIR="${CRD_DIR}/bases"
CRD_VERSION_PATCHES_DIR="${CRD_DIR}/patches/versions"
YQ="./$(dirname "$0")/tools/bin/yq"

for crd in "${CRD_BASE_DIR}"/*.yaml
do
    crd_name="$(yq e '.metadata.name' "$crd")"
    echo "$crd_name"

    for version in $(yq e '.spec.versions[].name' "$crd")
    do
        version_patches_dir="$CRD_VERSION_PATCHES_DIR/$version"
        mkdir -p "$version_patches_dir"

        patch_file="$version_patches_dir/$crd_name.yaml"
        rm -f "$patch_file"
        
        echo "   Writing $version version patch"
        echo "apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: ${crd_name}
spec:
    versions:
" > "$patch_file"

        # $YQ e '.spec.versions[] | select (.name == "'"$version"'")' "$crd" > "$patch_file"
        # $YQ eval-all -i '
        #     select(fileIndex==1).spec.versions[] | select (.name == "'"$version"'") |
        #     select(fileIndex==0).spec.versions += .
        # ' "$patch_file" "$crd"

        # echod="$(echo ".spec.versions[] | select (.name == \"$version\")" "$crd")"
        # echo "$echod"
        version_data="$($YQ e ".spec.versions[] | select (.name == \"$version\")" "$crd")" \
            $YQ e -i '.spec.versions = [env(version_data)]' "$patch_file"
        
        # echo "$version_field"
    done

    # Delete version data from the CRD base
    $YQ e -i 'del .spec.versions' "$crd"
done
