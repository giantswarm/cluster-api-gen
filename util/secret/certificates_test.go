/*
Copyright 2019 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package secret_test

import (
	"testing"

	. "github.com/onsi/gomega"

	"github.com/giantswarm/cluster-api-gen/bootstrap/kubeadm/types/v1beta1"
	"github.com/giantswarm/cluster-api-gen/util/secret"
)

func TestNewCertificatesForJoiningControlPlane_Stacked(t *testing.T) {
	g := NewWithT(t)

	certs := secret.NewCertificatesForJoiningControlPlane()
	g.Expect(certs.GetByPurpose(secret.EtcdCA).KeyFile).NotTo(BeEmpty())
}

func TesNewControlPlaneJoinCerts_Stacked(t *testing.T) {
	g := NewWithT(t)

	config := &v1beta1.ClusterConfiguration{}
	certs := secret.NewControlPlaneJoinCerts(config)
	g.Expect(certs.GetByPurpose(secret.EtcdCA).KeyFile).NotTo(BeEmpty())
}

func TestNewControlPlaneJoinCerts_External(t *testing.T) {
	g := NewWithT(t)

	config := &v1beta1.ClusterConfiguration{
		Etcd: v1beta1.Etcd{
			External: &v1beta1.ExternalEtcd{},
		},
	}

	certs := secret.NewControlPlaneJoinCerts(config)
	g.Expect(certs.GetByPurpose(secret.EtcdCA).KeyFile).To(BeEmpty())
}
