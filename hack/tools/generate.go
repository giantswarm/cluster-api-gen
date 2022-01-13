package tools

// Generate Cluster API core Go types
//go:generate go run github.com/giantswarm/apigen/cmd/goclone --org kubernetes-sigs --repo cluster-api --tag v0.4.5 --target-dir=../.. --additional-dir exp/api --additional-dir exp/addons/api --additional-dir controlplane/kubeadm/api --additional-dir bootstrap/kubeadm/api
