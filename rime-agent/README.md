# rime-agent

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.18.0](https://img.shields.io/badge/AppVersion-0.18.0-informational?style=flat-square)

A Helm chart for the Robust Intelligence Platform Agent, part of the Data Plane.

## Requirements

Kubernetes: `>=1.20.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| rimeAgent.apiKey | string | `nil` | the API key the agent will use to communicate with the RI Platform. |
| rimeAgent.commonAnnotations | object | `{}` |  |
| rimeAgent.commonLabels | object | `{}` |  |
| rimeAgent.connections.agentManagerAddress | string | `"rime-agent-manager-server:15000"` |  |
| rimeAgent.connections.dataCollectorRestAddress | string | `"rime-data-collector-server:15015"` |  |
| rimeAgent.connections.datasetManagerRestAddress | string | `"rime-dataset-manager-server:15009"` |  |
| rimeAgent.connections.firewallServerRestAddress | string | `"rime-firewall-server:15002"` |  |
| rimeAgent.connections.platformAddress | string | `nil` |  |
| rimeAgent.connections.uploadServerAddress | string | `"rime-upload-server:5000"` |  |
| rimeAgent.connections.uploadServerRestAddress | string | `"rime-upload-server:15001"` |  |
| rimeAgent.dockerCredentialsPayload | string | `nil` | pre-configured json encoded string of k8s docker config secret |
| rimeAgent.fullNameOverride | string | `nil` |  |
| rimeAgent.id | string | `nil` | unique ID for this Agent. Can be left blank if this is a internal agent. |
| rimeAgent.images.agentImage.name | string | `"robustintelligencehq/rime-agent:latest"` | the name and tag of the rime agent image. |
| rimeAgent.images.agentImage.pullPolicy | string | `"Always"` | see https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy |
| rimeAgent.images.agentImage.registry | string | `"docker.io"` | the registry of the agent image. |
| rimeAgent.images.imagePullSecrets | list | `[]` | use existing image pull secrets in your k8s cluster, overriding rimeAgent.dockerCredentials # Note that the credentials should provide access to both the Agent image and model testing images. |
| rimeAgent.images.modelTestJobImage.name | string | `"robustintelligencehq/rime-testing-engine-dev:latest"` |  |
| rimeAgent.images.modelTestJobImage.pullPolicy | string | `"Always"` | image pull policy for model test jobs. |
| rimeAgent.images.modelTestJobImage.registry | string | `"docker.io"` | the registry of the default model test job image. |
| rimeAgent.isInternal | bool | `false` |  |
| rimeAgent.launcher.deployment.affinity | object | `{}` |  |
| rimeAgent.launcher.deployment.annotations | object | `{}` |  |
| rimeAgent.launcher.deployment.extraEnv | list | `[]` |  |
| rimeAgent.launcher.deployment.extraVolumeMounts | list | `[]` |  |
| rimeAgent.launcher.deployment.extraVolumes | list | `[]` |  |
| rimeAgent.launcher.deployment.labels | object | `{}` |  |
| rimeAgent.launcher.deployment.nodeSelector | object | `{}` |  |
| rimeAgent.launcher.deployment.resources.limits.cpu | string | `"500m"` |  |
| rimeAgent.launcher.deployment.resources.limits.memory | string | `"500Mi"` |  |
| rimeAgent.launcher.deployment.resources.requests.cpu | string | `"100m"` |  |
| rimeAgent.launcher.deployment.resources.requests.memory | string | `"100Mi"` |  |
| rimeAgent.launcher.deployment.securityContext | object | `{}` |  |
| rimeAgent.launcher.deployment.tolerations | list | `[]` |  |
| rimeAgent.launcher.name | string | `"launcher"` |  |
| rimeAgent.launcher.serviceAccount.annotations | object | `{}` |  |
| rimeAgent.launcher.serviceAccount.create | bool | `true` |  |
| rimeAgent.launcher.serviceAccount.labels | object | `{}` |  |
| rimeAgent.launcher.serviceAccount.name | string | `nil` |  |
| rimeAgent.nameOverride | string | `nil` |  |
| rimeAgent.operator.deployment.affinity | object | `{}` |  |
| rimeAgent.operator.deployment.annotations | object | `{}` |  |
| rimeAgent.operator.deployment.extraEnv | list | `[]` |  |
| rimeAgent.operator.deployment.extraVolumeMounts | list | `[]` |  |
| rimeAgent.operator.deployment.extraVolumes | list | `[]` |  |
| rimeAgent.operator.deployment.labels | object | `{}` |  |
| rimeAgent.operator.deployment.nodeSelector | object | `{}` |  |
| rimeAgent.operator.deployment.resources.limits.cpu | string | `"500m"` |  |
| rimeAgent.operator.deployment.resources.limits.memory | string | `"128Mi"` |  |
| rimeAgent.operator.deployment.resources.requests.cpu | string | `"500m"` |  |
| rimeAgent.operator.deployment.resources.requests.memory | string | `"128Mi"` |  |
| rimeAgent.operator.deployment.securityContext | object | `{}` |  |
| rimeAgent.operator.deployment.tolerations | list | `[]` |  |
| rimeAgent.operator.logArchival.enabled | bool | `false` |  |
| rimeAgent.operator.modelTestJob.activeDeadlineSeconds | int | `259200` | active deadline of job in seconds. Default to 72 hours. |
| rimeAgent.operator.modelTestJob.affinity | object | `{}` | affinity for model test jobs. |
| rimeAgent.operator.modelTestJob.annotations | object | `{}` |  |
| rimeAgent.operator.modelTestJob.backoffLimit | int | `0` |  |
| rimeAgent.operator.modelTestJob.extraEnv | list | `[]` |  |
| rimeAgent.operator.modelTestJob.extraVolumeMounts | list | `[]` |  |
| rimeAgent.operator.modelTestJob.extraVolumes | list | `[]` |  |
| rimeAgent.operator.modelTestJob.labels | object | `{}` |  |
| rimeAgent.operator.modelTestJob.name | string | `"model-testing-job"` |  |
| rimeAgent.operator.modelTestJob.nodeSelector | object | `{}` | node selector for model test jobs. |
| rimeAgent.operator.modelTestJob.resources | object | `{"limits":{"cpu":"3000m","memory":"8000Mi"},"requests":{"cpu":"3000m","memory":"8000Mi"}}` | resource request and limits for model test jobs. |
| rimeAgent.operator.modelTestJob.securityContext | object | `{}` |  |
| rimeAgent.operator.modelTestJob.serviceAccount.annotations | object | `{}` | if create is true, annotations to add to the service account. # Since data is stored in a cloud storage (e.g. S3, GCS), add an annotation to allow read access here. # EKS IAM setup for S3: https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html # GKE IAM setup for GCS: https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity  Azure IAM setup: https://azure.github.io/azure-workload-identity/docs/ |
| rimeAgent.operator.modelTestJob.serviceAccount.create | bool | `true` | Specifies whether a ServiceAccount should be created. |
| rimeAgent.operator.modelTestJob.serviceAccount.name | string | `nil` | Specify a preexisting ServiceAccount to use if create is false. |
| rimeAgent.operator.modelTestJob.tolerations | list | `[]` | tolerations for model test jobs. |
| rimeAgent.operator.modelTestJob.ttlSecondsAfterFinished | int | `172800` | TTL for jobs after finished in seconds. Default to 48 hours. |
| rimeAgent.operator.name | string | `"operator"` |  |
| rimeAgent.operator.serviceAccount.annotations | object | `{}` |  |
| rimeAgent.operator.serviceAccount.create | bool | `true` |  |
| rimeAgent.operator.serviceAccount.labels | object | `{}` |  |
| rimeAgent.operator.serviceAccount.name | string | `""` |  |
| rimeAgent.verbose | bool | `true` |  |
| tls.crossplaneEnabled | bool | `false` |  |
| tls.enableCertManager | bool | `false` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
