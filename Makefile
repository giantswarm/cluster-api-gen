# DO NOT EDIT. Generated with:
#
#    devctl@4.9.2
#

# include Makefile.*.mk

##@ General

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk commands is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

# Directories
TOOLS_DIR := hack/tools
TOOLS_BIN_DIR := $(TOOLS_DIR)/bin
BIN_DIR := bin

# Binaries
KUSTOMIZE := $(abspath $(TOOLS_BIN_DIR)/kustomize)
CONTROLLER_GEN := $(abspath $(TOOLS_BIN_DIR)/controller-gen)

$(KUSTOMIZE): $(TOOLS_DIR)/go.mod # Build kustomize from tools folder.
	cd $(TOOLS_DIR); go build -tags=tools -o $(BIN_DIR)/kustomize sigs.k8s.io/kustomize/kustomize/v3

$(CONTROLLER_GEN): $(TOOLS_DIR)/go.mod # Build controller-gen from tools folder.
	cd $(TOOLS_DIR); go build -tags=tools -o $(BIN_DIR)/controller-gen sigs.k8s.io/controller-tools/cmd/controller-gen

.PHONY: ensure-tools
ensure-tools:
	./hack/ensure-yq.sh

.PHONY: generate-core-manifests
generate-core-manifests: $(CONTROLLER_GEN) ## Generate manifests for the core provider e.g. CRD, RBAC etc.
	$(CONTROLLER_GEN) \
		paths=./api/... \
		crd:crdVersions=v1 \
		output:crd:dir=./config/crd/bases \
		output:webhook:dir=./config/webhook \
		webhook

generate-core-patches:
	@cd hack; ./extract-crd-version-patches.sh

.PHONY: generate
generate:
	@cd hack/tools; go generate ./...
	@go mod tidy

.PHONY: build
build:
	@go build ./...

.PHONY: go-test
go-test:
	@go test ./api/...

.PHONY: delete-generated-go
delete-generated-go:
	@rm -rf api cmd exp util bootstrap controllers feature controlplane errors internal test

## --------------------------------------
## Release
## --------------------------------------

RELEASE_TAG := $(shell git describe --abbrev=0 2>/dev/null)
RELEASE_DIR := out

$(RELEASE_DIR):
	mkdir -p $(RELEASE_DIR)/

.PHONY: release-manifests
release-manifests: $(RELEASE_DIR) ## Builds the manifests to publish with a release
	# Build core-components.
	kustomize build config > $(RELEASE_DIR)/core-components.yaml
