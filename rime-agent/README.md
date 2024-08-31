# rime-agent

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.18.0](https://img.shields.io/badge/AppVersion-0.18.0-informational?style=flat-square)

A Helm chart for the Robust Intelligence Platform Agent, part of the Data Plane.

## Requirements

Kubernetes: `>=1.20.0-0`

| Repository | Name | Version |
|------------|------|---------|
| file://../ri-detection-resources | ri-detection-resources | 0.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ri-detection-resources | object | `{"enabled":false,"modelServers":{"factualInconsistency":{"enabled":false},"factualInconsistencyJa":{"enabled":false},"languageDetection":{"enabled":false},"promptInjectionMulticlass":{"enabled":false},"textEmbedding":{"enabled":false},"toxicityInterpretability":{"enabled":false}}}` | RI detection resources like model servers and YARA servers. These are used for GAI model testing. |
| rimeAgent.agentDeploymentLauncher.deployment.affinity | object | `{}` |  |
| rimeAgent.agentDeploymentLauncher.deployment.annotations | object | `{}` |  |
| rimeAgent.agentDeploymentLauncher.deployment.extraEnv | list | `[]` |  |
| rimeAgent.agentDeploymentLauncher.deployment.labels | object | `{}` |  |
| rimeAgent.agentDeploymentLauncher.deployment.nodeSelector | object | `{}` |  |
| rimeAgent.agentDeploymentLauncher.deployment.resources.limits.memory | string | `"100Mi"` |  |
| rimeAgent.agentDeploymentLauncher.deployment.resources.requests.cpu | string | `"100m"` |  |
| rimeAgent.agentDeploymentLauncher.deployment.resources.requests.memory | string | `"100Mi"` |  |
| rimeAgent.agentDeploymentLauncher.deployment.securityContext | object | `{}` |  |
| rimeAgent.agentDeploymentLauncher.deployment.tolerations | list | `[]` |  |
| rimeAgent.agentDeploymentLauncher.enabled | bool | `false` |  |
| rimeAgent.agentDeploymentLauncher.name | string | `"agent-deployment-launcher"` |  |
| rimeAgent.agentDeploymentLauncher.serviceAccount.annotations | object | `{}` |  |
| rimeAgent.agentDeploymentLauncher.serviceAccount.create | bool | `true` |  |
| rimeAgent.agentDeploymentLauncher.serviceAccount.labels | object | `{}` |  |
| rimeAgent.agentDeploymentLauncher.serviceAccount.name | string | `nil` |  |
| rimeAgent.agentDeploymentOperator.deployment.affinity | object | `{}` |  |
| rimeAgent.agentDeploymentOperator.deployment.annotations | object | `{}` |  |
| rimeAgent.agentDeploymentOperator.deployment.extraEnv | list | `[]` |  |
| rimeAgent.agentDeploymentOperator.deployment.extraVolumeMounts | list | `[]` |  |
| rimeAgent.agentDeploymentOperator.deployment.extraVolumes | list | `[]` |  |
| rimeAgent.agentDeploymentOperator.deployment.labels | object | `{}` |  |
| rimeAgent.agentDeploymentOperator.deployment.nodeSelector | object | `{}` |  |
| rimeAgent.agentDeploymentOperator.deployment.resources.limits.memory | string | `"300Mi"` |  |
| rimeAgent.agentDeploymentOperator.deployment.resources.requests.cpu | string | `"100m"` |  |
| rimeAgent.agentDeploymentOperator.deployment.resources.requests.memory | string | `"300Mi"` |  |
| rimeAgent.agentDeploymentOperator.deployment.securityContext | object | `{}` |  |
| rimeAgent.agentDeploymentOperator.deployment.tolerations | list | `[]` |  |
| rimeAgent.agentDeploymentOperator.name | string | `"agent-deployment-operator"` |  |
| rimeAgent.agentDeploymentOperator.serviceAccount.annotations | object | `{}` |  |
| rimeAgent.agentDeploymentOperator.serviceAccount.create | bool | `false` |  |
| rimeAgent.agentDeploymentOperator.serviceAccount.labels | object | `{}` |  |
| rimeAgent.agentDeploymentOperator.serviceAccount.name | string | `nil` |  |
| rimeAgent.apiKey | string | `nil` | The API key the agent will use to communicate with the RI Platform. This is temporary - it is only used for a brief interval to register the signing key. |
| rimeAgent.connections | object | (see individual values in `values.yaml`) | Service addresses for the agent. |
| rimeAgent.customCACertSecretName | string | `""` | Name of an existing K8s secret that contains the custom ca cert. |
| rimeAgent.detectionServer.deployment.affinity | object | `{}` |  |
| rimeAgent.detectionServer.deployment.annotations | object | `{}` |  |
| rimeAgent.detectionServer.deployment.extraEnv | list | `[]` |  |
| rimeAgent.detectionServer.deployment.extraVolumeMounts | list | `[]` |  |
| rimeAgent.detectionServer.deployment.extraVolumes | list | `[]` |  |
| rimeAgent.detectionServer.deployment.labels | object | `{}` |  |
| rimeAgent.detectionServer.deployment.nodeSelector | object | `{}` |  |
| rimeAgent.detectionServer.deployment.proxyResources.limits.memory | string | `"100Mi"` |  |
| rimeAgent.detectionServer.deployment.proxyResources.requests.cpu | string | `"10m"` |  |
| rimeAgent.detectionServer.deployment.proxyResources.requests.memory | string | `"100Mi"` |  |
| rimeAgent.detectionServer.deployment.replicaCount | int | `1` |  |
| rimeAgent.detectionServer.deployment.securityContext | object | `{}` |  |
| rimeAgent.detectionServer.deployment.serverResources.limits.memory | string | `"1200Mi"` |  |
| rimeAgent.detectionServer.deployment.serverResources.requests.cpu | string | `"250m"` |  |
| rimeAgent.detectionServer.deployment.serverResources.requests.memory | string | `"1200Mi"` |  |
| rimeAgent.detectionServer.deployment.tolerations | list | `[]` |  |
| rimeAgent.detectionServer.enableGrpcGateway | bool | `false` |  |
| rimeAgent.detectionServer.enabled | bool | `false` |  |
| rimeAgent.detectionServer.hpa.annotations | object | `{}` |  |
| rimeAgent.detectionServer.hpa.enabled | bool | `true` |  |
| rimeAgent.detectionServer.hpa.labels | object | `{}` |  |
| rimeAgent.detectionServer.hpa.maxReplicas | int | `10` |  |
| rimeAgent.detectionServer.hpa.metrics[0].resource.name | string | `"cpu"` |  |
| rimeAgent.detectionServer.hpa.metrics[0].resource.target.averageUtilization | int | `60` |  |
| rimeAgent.detectionServer.hpa.metrics[0].resource.target.type | string | `"Utilization"` |  |
| rimeAgent.detectionServer.hpa.metrics[0].type | string | `"Resource"` |  |
| rimeAgent.detectionServer.hpa.minReplicas | int | `1` |  |
| rimeAgent.detectionServer.name | string | `"detection-server"` |  |
| rimeAgent.detectionServer.port | int | `50053` |  |
| rimeAgent.detectionServer.proxyPort | int | `15053` |  |
| rimeAgent.detectionServer.service.annotations | object | `{}` |  |
| rimeAgent.detectionServer.service.labels | object | `{}` |  |
| rimeAgent.detectionServer.service.type | string | `"ClusterIP"` |  |
| rimeAgent.dockerCredentialsPayload | string | `nil` | Pre-configured json encoded string of K8s docker config secret Providing `rimeAgent.dockerCredentialsPayload` will override any provided inputs in rimeAgent.dockerCredentials |
| rimeAgent.existingSecretName | string | `""` | Name of an existing K8s secret containing the API key. If existingSecretName is set, the secret will not be created. Must have api-key set. |
| rimeAgent.existingSigningKeySecretName | string | `""` | Name of an existing K8s secret that contains the signing key. |
| rimeAgent.fileServer.config.endpoint | string | `"s3.amazonaws.com"` |  |
| rimeAgent.fileServer.config.storageBucketName | string | `""` | The bucket name of the S3 bucket used as the blob storage. |
| rimeAgent.fileServer.config.type | string | `"s3"` |  |
| rimeAgent.fileServer.deployment.affinity | object | `{}` |  |
| rimeAgent.fileServer.deployment.annotations | object | `{}` |  |
| rimeAgent.fileServer.deployment.extraEnv | list | `[]` |  |
| rimeAgent.fileServer.deployment.extraVolumeMounts | list | `[]` |  |
| rimeAgent.fileServer.deployment.extraVolumes | list | `[]` |  |
| rimeAgent.fileServer.deployment.labels | object | `{}` |  |
| rimeAgent.fileServer.deployment.nodeSelector | object | `{}` |  |
| rimeAgent.fileServer.deployment.replicaCount | int | `1` |  |
| rimeAgent.fileServer.deployment.resources.limits.memory | string | `"90Mi"` |  |
| rimeAgent.fileServer.deployment.resources.requests.cpu | string | `"100m"` |  |
| rimeAgent.fileServer.deployment.resources.requests.memory | string | `"90Mi"` |  |
| rimeAgent.fileServer.deployment.securityContext | object | `{}` |  |
| rimeAgent.fileServer.deployment.tolerations | list | `[]` |  |
| rimeAgent.fileServer.enabled | bool | `false` |  |
| rimeAgent.fileServer.hpa.annotations | object | `{}` |  |
| rimeAgent.fileServer.hpa.enabled | bool | `true` |  |
| rimeAgent.fileServer.hpa.labels | object | `{}` |  |
| rimeAgent.fileServer.hpa.maxReplicas | int | `10` |  |
| rimeAgent.fileServer.hpa.metrics[0].resource.name | string | `"cpu"` |  |
| rimeAgent.fileServer.hpa.metrics[0].resource.target.averageUtilization | int | `60` |  |
| rimeAgent.fileServer.hpa.metrics[0].resource.target.type | string | `"Utilization"` |  |
| rimeAgent.fileServer.hpa.metrics[0].type | string | `"Resource"` |  |
| rimeAgent.fileServer.hpa.minReplicas | int | `1` |  |
| rimeAgent.fileServer.name | string | `"file-server"` |  |
| rimeAgent.fileServer.port | int | `5022` |  |
| rimeAgent.fileServer.service.annotations | object | `{}` |  |
| rimeAgent.fileServer.service.labels | object | `{}` |  |
| rimeAgent.fileServer.service.type | string | `"ClusterIP"` |  |
| rimeAgent.fileServer.serviceAccount | object | `{"annotations":{"eks.amazonaws.com/role-arn":""},"create":true,"labels":{},"name":""}` | Account used by services that need access to blob storage. |
| rimeAgent.fileServer.serviceAccount.annotations."eks.amazonaws.com/role-arn" | string | `""` | Specify ARN of IRSA-enabled Blob Storage IAM role here |
| rimeAgent.id | string | `nil` | unique ID for this Agent. This id must be provided for creating agents. |
| rimeAgent.images | object | (see individual values in `values.yaml`) | Image specification for the Agent. |
| rimeAgent.launcher | object | (see individual values in `values.yaml`) | `launcher` K8s-level configurations |
| rimeAgent.monitoring | object | (see individual values in `values.yaml`) | `monitoring` (Datadog) K8s-level configurations |
| rimeAgent.monitoring.datadogEnabled | bool | `true` | Whether to enable Datadog autodiscovery tags for all services on the RIME agent |
| rimeAgent.monitoring.enabled | bool | `true` | Whether to enable Prometheus metrics for all services on the RIME agent |
| rimeAgent.monitoring.port | int | `8080` | Port to expose Prometheus metrics on |
| rimeAgent.operator | object | (see individual values in `values.yaml`) | `operator` K8s-level configurations |
| rimeAgent.operator.crossPlaneRPCJob | object | (see individual values in `values.yaml`) | `cross-plane-job` K8s-level configurations |
| rimeAgent.operator.generativeModelTestingRPCJob | object | (see individual values in `values.yaml`) | `gai-model-testjob` K8s-level configurations |
| rimeAgent.operator.logArchival | object | (see individual values in `values.yaml`) | Configuration for RIME Job Log Archival (persistence of job logs for debugging). |
| rimeAgent.operator.modelTestJob | object | (see individual values in `values.yaml`) | `model-testing-job` K8s-level configurations |
| rimeAgent.proxy.httpProxy | string | `""` |  |
| rimeAgent.proxy.httpsProxy | string | `""` |  |
| rimeAgent.proxy.noProxy | string | `""` |  |
| rimeAgent.proxy.proxyEnabled | bool | `false` |  |
| rimeAgent.registerAgent | object | (see individual values in `values.yaml`) | `registerAgent` K8s-level configurations |
| rimeAgent.rimeCrossPlaneServer | object | (see individual values in `values.yaml`) | `rime-cross-plane-server` K8s-level configurations |
| supportBundle.enabled | bool | `true` |  |
| tls | object | (see individual values in `values.yaml`) | Mutual TLS configuration for internal agent. |
| tls.certificateSpec | object | `{"issuerRef":{"group":"cert-manager.io","kind":"Issuer","name":""},"subject":{"organizations":["RobustIntelligence"]}}` | `spec` for Certificate object (https://cert-manager.io/docs/usage/certificate/). |
| tls.certificateSpec.issuerRef | object | `{"group":"cert-manager.io","kind":"Issuer","name":""}` | See https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.CertificateSpec Attributes listed below are the minimum required `issuerRef` property. |
| tls.certificateSpec.issuerRef.name | string | `""` | Will default to `rime-{{ .Release.Namespace }}-ca-issuer`. |
| tls.certificateSpec.subject | object | `{"organizations":["RobustIntelligence"]}` | See https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.CertificateSpec Attributed listed below are the minimum required for the `subject` property. |
| tls.customCACert | string | `""` | custom ca cert; it should be in PEM format and no need to be base64 encoded. only used when cert manager is not enabled. |
| tls.enableCertManager | bool | `false` | Whether to enable the cert-manager service for issuing and managing TLS certificates within the cluster |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
