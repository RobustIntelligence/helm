# The Robust Intelligence Helm Charts
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

---

# Deployment

## `rime`
TODO

## `rime-agent`
TODO

## `rime-extras`
TODO

## `rime-kube-system`
TODO

---

## License

Copyright &copy; 2023 Robust Intelligence

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.
