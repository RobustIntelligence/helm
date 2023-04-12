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

## `rime`

<details>
<summary>Prerequisites</summary>
TODO
</details>

### Configuring Parameters
TODO
### Installing the Chart
TODO
### Uninstalling the Chart
TODO

## `rime-agent`
### Prerequisites
TODO
### Configuring Parameters
TODO
### Installing the Chart
TODO
### Uninstalling the Chart
TODO

## `rime-extras` (Recommended)
### Prerequisites
TODO
### Configuring Parameters
TODO
### Installing the Chart
TODO
### Uninstalling the Chart
TODO

## `rime-kube-system` (Recommended)
### Prerequisites
TODO
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
