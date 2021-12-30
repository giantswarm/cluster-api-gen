#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

CRD_DIR="./$(dirname "$0")/../config/crd"
CRD_BASE_DIR="${CRD_DIR}/bases"
CRD_VERSION_PATCHES_DIR="${CRD_DIR}/patches/versions"
YQ="./$(dirname "$0")/tools/bin/yq"

KUSTOMIZATION_FILE="${CRD_DIR}/kustomization.yaml"

cat > "$KUSTOMIZATION_FILE" << EOF
resources:

patchesStrategicMerge:

EOF

for crd in "${CRD_BASE_DIR}"/*.yaml
do
    crd_name="$(yq e '.metadata.name' "$crd")"
    echo "$crd_name"
    crd_filename="$(basename "$crd")"

    # Add CRD base to kustomization.yaml
    $YQ eval -i '.resources += ["bases/'"$crd_filename"'"]' "$KUSTOMIZATION_FILE"

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

        version_data="$($YQ e ".spec.versions[] | select (.name == \"$version\")" "$crd")" \
            $YQ e -i '.spec.versions = [env(version_data)]' "$patch_file"
        
        # Add CRD version patches to kustomization.yaml
        $YQ eval -i '.patchesStrategicMerge += ["patches/versions/'"$version/$crd_filename"'"]' "$KUSTOMIZATION_FILE"
    done

    # Delete version data from the CRD base
    $YQ e -i 'del .spec.versions' "$crd"
done
