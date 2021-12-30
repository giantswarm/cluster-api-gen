#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

MIN_VERSION=v4.16.2
OS="$(go env GOOS)"
ARCH="$(go env GOARCH)"
BINARY="yq_${OS}_${ARCH}"

YQPATH="./$(dirname "$0")/tools/bin/yq"
if [ ! -f "$YQPATH" ]; then
  # install yq
  curl -L "https://github.com/mikefarah/yq/releases/download/${MIN_VERSION}/${BINARY}" -o "${YQPATH}"
  chmod +x "${YQPATH}"
fi

# wget https://github.com/mikefarah/yq/releases/download/${MIN_VERSION}/${BINARY} -O /usr/bin/yq &&\
#     chmod +x /usr/bin/yq
