# Robust Intelligence Helm Charts
<picture>
 <source  media="(prefers-color-scheme: dark)" srcset="https://assets-global.website-files.com/62a7e9e01c9610dd11622fc6/62a8d4255468bd5859438043_logo-ri-white.svg">
 <source  media="(prefers-color-scheme: light)" height="70px" srcset="https://www.ai-expo.net/northamerica/wp-content/uploads/2022/07/RI-Logo-Stacked-Dark-Transparent.jpg">
 <img alt="Robust Intelligence Logo" src="YOUR-DEFAULT-IMAGE">
</picture>

<br />
<br />

```
helm repo add robustintelligence https://robustintelligence.github.io/helm --force-update
```
This repository contains 3 Helm charts:
- `ri-firewall`
  - AI Firewall installation
- `rime-kube-system`
  - K8s Cluster and ML infrastructure services, such as [External DNS](https://github.com/kubernetes-sigs/external-dns/tree/master/charts/external-dns) and kServe
- `rime-extras` (recommended)
  - 3rd-party add-ons like DataDog monitoring

Detailed READMEs for each chart are in the subfolders.

# Self-Hosted Installation
For a standalone Robust Intelligence Firewall, both the `ri-firewall` and `rime-kube-system` charts are necessary.

### General Prerequisites
1. A Kubernetes cluster (version 1.24 or greater)
    - (AWS EKS) enable [IAM roles for service accounts (IRSA)](https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up-enable-IAM.html)
2. A dedicated K8s namespace for Robust Intelligence
3. Access to the kube-system namespace in this K8s cluster
4. [Helm](https://helm.sh/) (version 3)
5. [kubectl](https://kubernetes.io/docs/reference/kubectl/kubectl/)
6. A read token for the Robust Intelligence artifact repository as a [K8s secret](https://kubernetes.io/docs/concepts/configuration/secret/#docker-config-secrets) (will be provided by your Solutions Architect)
7. Ensure that the following URLs have been whitelisted for your K8s cluster.
   - Robust Intelligence Private Dockerhub Repositories: https://hub.docker.com/repository/docker/robustintelligencehq/
   - Robust Intelligence Private Github Repository for YARA signatures: https://github.com/RobustIntelligence/rime-yara
   - Robust Intelligence Private Huggingface Model Hub: https://huggingface.co/robustintelligence/

## `rime-kube-system`
NOTE: Resources for the `rime-kube-system` pertain to infrastructure services like the [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/cluster-autoscaler-1.21.0/cluster-autoscaler/cloudprovider) or [External DNS](https://github.com/kubernetes-sigs/external-dns/tree/v0.12.0/charts/external-dns); therefore, they are deployed in the `kube-system` namespace.

<details>
<summary><h3>Prerequisites</h3></summary>

1. Permissions to create resources in the `kube-system` namespace
2. [kserve](https://github.com/kserve/kserve) prerequisites
3. [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/cluster-autoscaler-1.21.0/cluster-autoscaler/cloudprovider) prerequisites (recommended)
4. [External DNS](https://github.com/kubernetes-sigs/external-dns/tree/v0.12.0/charts/external-dns) prerequisites (recommended)
5. [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/) prerequisites (recommended, AWS-only)
6. [Metrics Server](https://github.com/kubernetes-sigs/metrics-server/tree/v0.6.1) prerequisites (recommended, necessary for autoscaling)

</details>

### Configuring Parameters
For a detailed overview of this chart's values, see the `rime-kube-system` README [here](./rime-kube-system). Your Solutions Architect will assist with configuring parameters during deployment.

### Installing the Chart
```
# When ready to deploy, remove --dry-run
helm upgrade -i rime-kube-system robustintelligence/rime-kube-system \
  --version $RI_FIREWALL_VERSION \
  --values $RIME_KUBE_SYSTEM_VALUES_FILE \
  --namespace kube-system \
  --debug \
  --dry-run
```


#### Uninstalling the Chart
```
helm uninstall rime-kube-system -n kube-system
```

## `ri-firewall`
<details>
<summary><h3>Prerequisites</h3></summary>

#### General
1. A domain for your service
    - A TLS certificate
2. A product license (will be provided by your Solutions Architect)

#### AWS (EKS)
1. A domain for your service managed by [Route53](https://aws.amazon.com/route53/)
    - A TLS certificate in ACM

</details>

### Configuring Parameters
For a detailed overview of this chart's values, see the `ri-firewall` README [here](./ri-firewall). Your Solutions Architect will assist with configuring parameters during deployment.

Some of the main sections to configure include:
1. `riFirewall.secrets`: application secrets for auth0-based authentication and RI-provided keys.
    - Your Solutions Architect will guide you through the creation process of the K8s secret for `rime.secrets.existingIntegrationSecretsName`
    - If enabling auth0, parameters and secrets can be provided via the `riFirewall.secrets.auth0` fields or via a pre-created K8s secret with name specified in `rime.secrets.existingAuthSecretsName`
2. `riFirewall.yaraServer.gitRepoToken`: read-only access to an RI-managed github repository of YARA signatures (recommended)
    - Your Solutions Architect will provide a token.
3. `ingress-nginx`: settings for the [Ingress-NGINX Controller](https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx)
    - Specify `ingress-nginx.controller.service.annotations` for your load balancing configuration

### Installing the Chart
```
# When ready to deploy, remove --dry-run
helm upgrade -i ri-firewall robustintelligence/ri-firewall \
  --version $RI_FIREWALL_VERSION \
  --values $RIME_VALUES_FILE \
  --namespace $RI_NAMESPACE \
  --debug \
  --dry-run
```

#### Uninstalling the Chart
```
helm uninstall ri-firewall -n $RI_NAMESPACE
```

## `rime-extras` (Recommended)
It's recommended to deploy the `rime-extras` chart in a separate namespace (e.g., called `rime-extras`).

<details>
<summary><h3>Prerequisites</h3></summary>

1. [DataDog](https://github.com/DataDog/helm-charts/tree/datadog-2.20.3/charts/datadog) prerequisites
    - A DataDog API key (will be provided by your Solutions Architect)
</details>

### Configuring Parameters
For a detailed overview of this chart's values, see the `rime-extras` README [here](./rime-extras). Your Solutions Architect will assist with configuring parameters during deployment.

For DataDog, you may wish to configure the log masking logic specified in `datadog.datadog.env`.

For Velero, you may wish to configure the backup schedule and horizon in `velero.schedules.mongodb-backup`.

### Installing the Chart
```
# When ready to deploy, remove --dry-run
helm upgrade -i rime-extras robustintelligence/rime-extras \
  --version $RI_VERSION \
  --values $RIME_EXTRAS_VALUES_FILE \
  --namespace $RIME_EXTRAS_NAMESPACE \
  --debug \
  --dry-run
```

#### Uninstalling the Chart
```
helm uninstall rime-extras -n $RIME_EXTRAS_NAMESPACE
```

---

## License

Copyright &copy; 2024 Robust Intelligence

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.
