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

### Recommended K8s Cluster Configuration
The core charts (`rime` and `rime-agent`) can be deployed to a single namespace.
Additionally, we recommend the following:
1. A dedicated node group (with autoscaling) for the `rime-agent` workloads
    - Label: `dedicated=model-testing`, Taint: `dedicated=model-testing:NoSchedule`
2. An expandable and encrypted [StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/) for services in the Robust Intelligence namespace

## `rime`

<details>
<summary><h3>Prerequisites</h3></summary>

#### General
1. A read token for the Robust Intelligence artifact repository (will be provided by your Solutions Architect)
2. A domain for your service
    - A TLS certificate

#### AWS (EKS)
1. A read token for the Robust Intelligence artifact repository as a [K8s secret](https://kubernetes.io/docs/concepts/configuration/secret/#docker-config-secrets)
2. A domain for your service managed by [Route53](https://aws.amazon.com/route53/)
    - A TLS certificate in ACM (recommended)
3. **Managed Images** prerequisites (add-on feature)
    - An Elastic Container Registry (ECR)
    - IAM permissions for Image Builder role
    - IAM permissions for Repo Manager role

#### GCP (GKE)
1. A read token for the Robust Intelligence artifact repository as a [K8s secret](https://kubernetes.io/docs/concepts/configuration/secret/#docker-config-secrets)
2. A domain for your service managed by [Cloud DNS](https://cloud.google.com/dns/)
    - A TLS certificate as a [K8s secret](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets)

#### Azure (AKS)
1. A read token for the Robust Intelligence artifact repository as a [K8s secret](https://kubernetes.io/docs/concepts/configuration/secret/#docker-config-secrets)
2. A domain for your service
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

## `rime-kube-system` (Recommended)

<details>
<summary><h3>Prerequisites</h3></summary>
TODO IAM
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
