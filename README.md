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
This repository contains 4 Helm charts:
- `rime`
  - Core application services (i.e., the *control plane*)
- `rime-agent`
  - Model Testing agent (i.e., the *data plane*)
- `rime-extras` (recommended)
  - 3rd-party add-ons like Velero backups or DataDog monitoring
- `rime-kube-system` (recommended)
  - K8s Cluster infrastructure services, such as [External DNS](https://github.com/kubernetes-sigs/external-dns/tree/master/charts/external-dns)

Detailed READMEs for each chart are in the subfolders.

# Installation

**For a standard installation, you need only install the `rime-agent` chart in a K8s namespace, which is auto-configured during the guided installation process.**

Please refer to Installation in the product documentation for details:
- [Installation](https://docs.robustintelligence.com/en/2.3-stable/deployment/index.html)

For **Self-Hosted** deployments, see below.

---

# Self-Hosted Installation
For a standalone Robust Intelligence cluster, both the `rime` and `rime-agent` charts are necessary, and it is recommended to install both `rime-extras` and `rime-kube-system` (unless the contained functionalities already exist in your K8s cluster).

### General Prerequisites
1. A Kubernetes cluster (version 1.24 or greater)
    - (AWS EKS) enable [IAM roles for service accounts (IRSA)](https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up-enable-IAM.html)
    - (GCP GKE) enable [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
    - (Azure AKS) enable [Workload Identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview) (recommended)
2. A dedicated K8s namespace for Robust Intelligence
3. [Helm](https://helm.sh/) (version 3)
4. [kubectl](https://kubernetes.io/docs/reference/kubectl/kubectl/)
5. A read token for the Robust Intelligence artifact repository as a [K8s secret](https://kubernetes.io/docs/concepts/configuration/secret/#docker-config-secrets) (will be provided by your Solutions Architect)

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
2. [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/cluster-autoscaler-1.21.0/cluster-autoscaler/cloudprovider) prerequisites (recommended)
3. [External DNS](https://github.com/kubernetes-sigs/external-dns/tree/v0.12.0/charts/external-dns) prerequisites (recommended)
4. [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/) prerequisites (recommended, AWS-only)
5. [Metrics Server](https://github.com/kubernetes-sigs/metrics-server/tree/v0.6.1) prerequisites (recommended, necessary for autoscaling)

#### GCP (GKE)
NOTE: The [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/cluster-autoscaler-1.21.0/cluster-autoscaler/cloudprovider) and [Metrics Server](https://github.com/kubernetes-sigs/metrics-server/tree/v0.6.1) come configured by default with GKE clusters, so no additional configuration is necessary.

#### Azure (AKS)
NOTE: The [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/cluster-autoscaler-1.21.0/cluster-autoscaler/cloudprovider) and [Metrics Server](https://github.com/kubernetes-sigs/metrics-server/tree/v0.6.1) come configured by default with AKS clusters, so no additional configuration is necessary.

</details>

### Configuring Parameters
For a detailed overview of this chart's values, see the `rime-kube-system` README [here](./rime-kube-system). Your Solutions Architect will assist with configuring parameters during deployment.

Note that if deploying [cert-manager](https://github.com/cert-manager/cert-manager/tree/v1.10.0) for internal TLS (recommended), CRDs will be created. These CRDS must be created *before* deploying any other Robust Intelligence charts.

### Installing the Chart
```
# When ready to deploy, remove --dry-run
helm upgrade -i rime-kube-system robustintelligence/rime-kube-system \
  --version $RI_VERSION \
  --values $RIME_KUBE_SYSTEM_VALUES_FILE \
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
2. A product license (will be provided by your Solutions Architect)

#### AWS (EKS)
1. A domain for your service managed by [Route53](https://aws.amazon.com/route53/)
    - A TLS certificate in ACM
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
For a detailed overview of this chart's values, see the `rime` README [here](./rime). Your Solutions Architect will assist with configuring parameters during deployment.

Some of the main sections to configure include:
1. `rime.secrets`: application secrets for product license, admin one-time credentials, etc.
    - (use `rime.secrets.existingSecretName` to specify these values through a K8s secret)
2. `rime.datasetManagerServer`: settings for the **Managed Blob Storage** feature (AWS-only)
    - If enabling this feature, set `rime.datasetManagerServer.enabled: true` and specify the Managed Blob Storage IAM role
3. `rime.imageRegistryServer`: settings for the **Managed Images** feature (AWS-only)
    - If enabling this feature, set `rime.imageRegistryServer.enabled: true` and specify the Image Builder and Repo Manager IAM roles
4. `ingress-nginx`: settings for the [Ingress-NGINX Controller](https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx)
    - Specify `ingress-nginx.controller.service.annotations` for your load balancing configuration
5. `tls`: whether to enable internal TLS for specific services

### Installing the Chart
```
# When ready to deploy, remove --dry-run
helm upgrade -i rime robustintelligence/rime \
  --version $RI_VERSION \
  --values $RIME_VALUES_FILE \
  --namespace $RI_NAMESPACE \
  --debug \
  --dry-run
```

#### Uninstalling the Chart
```
helm uninstall rime -n $RI_NAMESPACE
```

## `rime-agent`
<details>
<summary><h3>Prerequisites</h3></summary>

#### General
1. A blob storage entity
2. An authorization policy allowing read access to ^

#### AWS (EKS)
1. A blob storage entity ([S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingBucket.html))
2. An authorization policy allowing read access to ^ ([IAM role](https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html))

#### GCP (GKE)
1. A blob storage entity ([Cloud Storage bucket](https://cloud.google.com/storage/docs/buckets))
2. An authorization policy allowing read access to ^ ([Service Account](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity))

#### Azure (AKS)
1. A [Storage Account](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview)
2. A blob storage entity ([Blob Storage Container](https://learn.microsoft.com/en-us/azure/storage/blobs/blob-containers-portal))
3. An authorization policy allowing read access to ^ ([Managed Identity](https://learn.microsoft.com/en-us/azure/aks/learn/tutorial-kubernetes-workload-identity#create-a-managed-identity-and-grant-permissions-to-access-the-secret))

</details>

### Configuring Parameters
For a detailed overview of this chart's values, see the `rime-agent` README [here](./rime-agent). Your Solutions Architect will assist with configuring parameters during deployment.

Generally, there are two main setup steps for the `rime-agent` Helm chart:
1. Identify the authorization for the `rime-agent-model-tester` ServiceAccount under `rimeAgent.modelTestJob.serviceAccount`.
2. Configure endpoints in the `rimeAgent.connections` section.
    - For **internal** agents (i.e., within the same cluster, which is the default for Self-Hosted deployments):
        - Each endpoint takes the form `${RIME_RELEASE_NAME}-${SERVER_NAME}.${RIME_NAMESPACE}:${PORT}` (e.g., `rime-acme-agent-manager-server.acme:5016`).
        - If enabling mutual TLS within the cluster, the `*RestAddress` endpoints must have HTTPS enabled (e.g., `https://rime-acme-agent-manager-server.acme:5016`).
    - For **external** agents (i.e., outside of the cluster):
        - Only specify `rimeAgent.connections.platformAddress`, which should be the domain of your web application.

### Installing the Chart
```
# When ready to deploy, remove --dry-run
helm upgrade -i rime-agent robustintelligence/rime-agent \
  --version $RI_VERSION \
  --values $RIME_AGENT_VALUES_FILE \
  --namespace $RI_NAMESPACE \
  --debug \
  --dry-run
```

#### Uninstalling the Chart
```
helm uninstall rime-agent -n $RI_NAMESPACE
```

## `rime-extras` (Recommended)
It's recommended to deploy the `rime-extras` chart in a separate namespace (e.g., called `rime-extras`).

<details>
<summary><h3>Prerequisites</h3></summary>

1. [DataDog](https://github.com/DataDog/helm-charts/tree/datadog-2.20.3/charts/datadog) prerequisites
    - A DataDog API key (will be provided by your Solutions Architect)
2. [Velero](https://github.com/vmware-tanzu/helm-charts/tree/velero-2.23.6/charts/velero) prerequisites
    - Follow the [setup instructions](https://velero.io/docs/v1.6/supported-providers/) for your provider

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

Copyright &copy; 2023 Robust Intelligence

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.
