package tools

// Generate Cluster API core Go types
//go:generate go run github.com/giantswarm/apigen/cmd/goclone --org kubernetes-sigs --repo cluster-api --tag v1.0.5 --api-version=v1beta1 --target-dir=../.. --additional-dir exp/api --additional-dir exp/addons/api --additional-dir controlplane/kubeadm/api --additional-dir bootstrap/kubeadm/api --exclude "*_test.go" --exclude "*_webhook.go"
