package tools

// Generate Cluster API core Go types
//go:generate go run github.com/giantswarm/apigen/cmd/goclone -org kubernetes-sigs -repo cluster-api -tag v0.3.24 -target-dir=../..
