//go:build tools
// +build tools

package tools

import (
	_ "github.com/giantswarm/apigen/cmd/goclone"
	_ "sigs.k8s.io/controller-tools/cmd/controller-gen"
)
