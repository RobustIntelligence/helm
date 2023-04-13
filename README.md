# The Robust Intelligence Helm Charts
TODO logo here

```
helm repo add robustintelligence https://robustintelligence.github.io/helm --force-update
```
This repository contains 4 Helm charts:
- `rime`
  - Core application services (i.e., the *control plane*)
- `rime-agent`
  - Model Testing agent (i.e., the *data plane*)
- `rime-extras` (optional)
  - 3rd-party add-ons like Velero backups or DataDog monitoring
- `rime-kube-system` (optional)
  - K8s Cluster infrastructure services, such as [External DNS](https://github.com/kubernetes-sigs/external-dns/tree/master/charts/external-dns)

Detailed READMEs for each chart are in the subfolders.

# Installation

For standard installation, you need only install the `rime-agent` chart in a K8s namespace, which is auto-configured during the guided installation process.

Please refer to Installation in the product documentation for details:
- [Installation](https://docs.rime.dev/en/2.0.0/installation/index.html)

For **Self-Hosted** deployments, see below.

---

# Self-Hosted Installation
For a standalone Robust Intelligence cluster, both the `rime` and `rime-agent` charts are necessary, and it is recommended to install both `rime-extras` and `rime-kube-system` (unless the contained functionalities already exist in your K8s cluster).

### General Prerequisites
1. A Kubernetes cluster (version 1.23 or greater)
    - A dedicated Robust Intelligence namespace
2. [Helm](https://helm.sh/) (version 3)
3. [kubectl](https://kubernetes.io/docs/reference/kubectl/kubectl/)
4. A read token for the Robust Intelligence artifact repository as a [K8s secret](https://kubernetes.io/docs/concepts/configuration/secret/#docker-config-secrets)

### Recommended K8s Cluster Configuration
The core charts (`rime` and `rime-agent`) can be deployed to a single namespace.
Additionally, we recommend the following:
1. A dedicated node group (with autoscaling) for the `rime-agent` workloads
    - Label: `dedicated=model-testing`, Taint: `dedicated=model-testing:NoSchedule`
2. An expandable and encrypted [StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/) for services in the Robust Intelligence namespace

## `rime-kube-system` (Recommended)

NOTE: Resources for the `rime-kube-system` pertain to infrastructure services like the [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/cluster-autoscaler-1.21.0/cluster-autoscaler/cloudprovider) or [External DNS](https://github.com/kubernetes-sigs/external-dns/tree/v0.12.0/charts/external-dns); therefore, they are deployed in the `kube-system` namespace.

<details>
<summary><h3>Prerequisites</h3></summary>

1. Permissions to create resources in the `kube-system` namespace
1. [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/cluster-autoscaler-1.21.0/cluster-autoscaler/cloudprovider) prerequisites (recommended)
2. [External DNS](https://github.com/kubernetes-sigs/external-dns/tree/v0.12.0/charts/external-dns) prerequisites (recommended)
3. [AWS Load Balancer Controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller/tree/v2.4.2) prerequisites (recommended, AWS-only)
4. [Metrics Server](https://github.com/kubernetes-sigs/metrics-server/tree/v0.6.1) prerequisites (recommended, necessary for autoscaling)

</details>

### Configuring Parameters
For a detailed overview of this chart's values, see the `rime-kube-system` README [here](). Your Solutions Architect will assist with configuring parameters during deployment.

Note that if deploying [cert-manager](https://github.com/cert-manager/cert-manager/tree/v1.10.0) for internal TLS (recommended), CRDs will be created. These CRDS must be created *before* deploying any other Robust Intelligence charts.

### Installing the Chart
```
# When ready to deploy, remove --dry-run
helm upgrade -i rime-kube-system robustintelligence/rime-kube-system \
  --version $RI_VERSION \
  --values $VALUES_FILE \
  --namespace kube-system \
  --debug \
  --dry-run
```

#### Uninstalling the Chart
```
helm uninstall rime-kube-system -n kube-system
```

## `rime`

<details>
<summary><h3>Prerequisites</h3></summary>

#### General
1. A domain for your service
    - A TLS certificate

#### AWS (EKS)
1. A domain for your service managed by [Route53](https://aws.amazon.com/route53/)
    - A TLS certificate in ACM (recommended)
2. **Managed Images** prerequisites (add-on feature)
    - An Elastic Container Registry (ECR)
    - IAM permissions for Image Builder role
    - IAM permissions for Repo Manager role

#### GCP (GKE)
1. A domain for your service managed by [Cloud DNS](https://cloud.google.com/dns/)
    - A TLS certificate as a [K8s secret](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets)

#### Azure (AKS)
1. A domain for your service
    - A TLS certificate as a [K8s secret](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets)

</details>

### Configuring Parameters
TODO
### Installing the Chart
TODO
### Uninstalling the Chart
TODO

## `rime-agent`

<details>
<summary><h3>Prerequisites</h3></summary>

1. A blob storage entity
2. An authorization policy allowing read access to ^

</details>

### Configuring Parameters
TODO
### Installing the Chart
TODO
### Uninstalling the Chart
TODO

## `rime-extras` (Recommended)

<details>
<summary><h3>Prerequisites</h3></summary>
TODO S3 Buckets, IAM, DataDog key
</details>

### Configuring Parameters
TODO
### Installing the Chart
TODO
### Uninstalling the Chart
TODO

---

## License

Copyright &copy; 2023 Robust Intelligence

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.
