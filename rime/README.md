# rime

![Version: 2.0.2](https://img.shields.io/badge/Version-2.0.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2.0.0](https://img.shields.io/badge/AppVersion-v2.0.0-informational?style=flat-square)

A Helm chart for RIME's hosted services

## Requirements

Kubernetes: `>=1.20.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | mongodb | 12.1.27 |
| https://helm.releases.hashicorp.com | vault | 0.23.0 |
| https://kubernetes.github.io/ingress-nginx | ingress-nginx | 4.7.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| external.mongo | object | `{"databaseName":"","enabled":false,"replicaSetName":"","secretName":"","url":"","urlPrefix":""}` | Whether to use an external MongoDB instance |
| external.vault | object | `{"enabled":false,"kvVersion":"","mountPath":"","namespace":"","roleName":"","secretName":"","url":""}` | Whether to use an external Vault instance |
| ingress-nginx | object | (see individual values in `values`.yaml) | Ingress-nginx controller sub-chart. See https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx for all parameters. |
| ingress-nginx.controller.scope.namespace | string | `""` | K8s namespace for the ingress |
| ingress-nginx.controller.service.annotations | object | `{"service.beta.kubernetes.io/aws-load-balancer-backend-protocol":"ssl","service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout":"3600","service.beta.kubernetes.io/aws-load-balancer-nlb-target-type":"ip","service.beta.kubernetes.io/aws-load-balancer-scheme":"internet-facing","service.beta.kubernetes.io/aws-load-balancer-ssl-cert":"","service.beta.kubernetes.io/aws-load-balancer-ssl-ports":"https","service.beta.kubernetes.io/aws-load-balancer-type":"external"}` | For full list of annotations, see https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/service/annotations/ |
| ingress-nginx.controller.service.annotations."service.beta.kubernetes.io/aws-load-balancer-scheme" | string | `"internet-facing"` | NLB specification: either "internal" or "internet-facing" |
| ingress-nginx.controller.service.annotations."service.beta.kubernetes.io/aws-load-balancer-ssl-cert" | string | `""` | Specifies the ARN of one or more certificates managed by the AWS Certificate Manager. |
| mongodb | object | (see individual values in `values`.yaml) | MongoDB sub-chart. See https://artifacthub.io/packages/helm/bitnami/mongodb for all parameters. |
| mongodb.persistence.size | string | `"32Gi"` | Size of the PVs for MongoDB storage. |
| mongodb.persistence.storageClass | string | `"expandable-storage"` | Name of the StorageClass for MongoDB. Should be of the form "mongo-storage-$NAMESPACE" |
| rime | object | (see individual values in `values`.yaml) | Global variables used by all RIME services. |
| rime.agentManagerServer | object | (see individual values in `values.yaml`) | `agentManagerServer` K8s-level configurations |
| rime.agentManagerServer.existingConfigSecretName | string | `""` | Use if MANUALLY creating a Secret to replace the default internal service configuration. NOTE: This Secret's schema MUST match that of the corresponding default defined in /templates/**/configmap.yaml. |
| rime.authServer | object | (see individual values in `values.yaml`) | `authServer` K8s-level configurations |
| rime.authServer.existingConfigSecretName | string | `""` | Use if MANUALLY creating a Secret to replace the default internal service configuration. NOTE: This Secret's schema MUST match that of the corresponding default defined in /templates/**/configmap.yaml. |
| rime.dataCollectorServer | object | (see individual values in `values.yaml`) | `dataCollectorServer` K8s-level configurations |
| rime.dataCollectorServer.existingConfigSecretName | string | `""` | Use if MANUALLY creating a Secret to replace the default internal service configuration. NOTE: This Secret's schema MUST match that of the corresponding default defined in /templates/**/configmap.yaml. |
| rime.datasetManagerServer | object | (see individual values in `values.yaml`) | `datasetManagerServer` K8s-level configurations |
| rime.datasetManagerServer.config.storageBucketName | string | `""` | The bucket name of the S3 bucket used as the blob storage. |
| rime.datasetManagerServer.existingConfigSecretName | string | `""` | Use if MANUALLY creating a Secret to replace the default internal service configuration. NOTE: This Secret's schema MUST match that of the corresponding default defined in /templates/**/configmap.yaml. |
| rime.datasetManagerServer.serviceAccount | object | `{"annotations":{"eks.amazonaws.com/role-arn":""},"create":true,"labels":{},"name":""}` | Account used by services that need access to blob storage. |
| rime.datasetManagerServer.serviceAccount.annotations."eks.amazonaws.com/role-arn" | string | `""` | Specify ARN of IRSA-enabled Blob Storage IAM role here |
| rime.domain | string | `""` | Base domain of the RIME web app, which will consist of `rime.${domain}` |
| rime.featureFlagServer | object | (see individual values in `values.yaml`) | `featureFlagServer` K8s-level configurations |
| rime.featureFlagServer.existingConfigSecretName | string | `""` | Use if MANUALLY creating a Secret to replace the default internal service configuration. NOTE: This Secret's schema MUST match that of the corresponding default defined in /templates/**/configmap.yaml. |
| rime.featureFlagServer.serviceAccount | object | `{"annotations":{"eks.amazonaws.com/role-arn":""},"labels":{},"name":""}` | Account used by services that need access the s3 license. |
| rime.featureFlagServer.serviceAccount.annotations."eks.amazonaws.com/role-arn" | string | `""` | Specify ARN of IRSA-enabled Blob Storage IAM role here |
| rime.firewallServer | object | (see individual values in `values.yaml`) | `firewallServer` K8s-level configurations |
| rime.firewallServer.existingConfigSecretName | string | `""` | Use if MANUALLY creating a Secret to replace the default internal service configuration. NOTE: This Secret's schema MUST match that of the corresponding default defined in /templates/**/configmap.yaml. |
| rime.firewallServer.scheduledCTCron | object | `{"annotations":{},"enabled":true,"labels":{},"name":"scheduled-ct-cron","schedule":"*/20 * * * *"}` | Configuration for scheduled Continuous Testing |
| rime.frontendServer | object | (see individual values in `values.yaml`) | `frontendServer` K8s-level configurations |
| rime.imageRegistryServer | object | (see individual values in `values.yaml`) | `imageRegistryServer` K8s-level configurations |
| rime.imageRegistryServer.config | object | `{}` | Comment this section (see below) if using the Managed Images feature |
| rime.imageRegistryServer.enabled | bool | `false` | Whether to enable the Managed Images feature |
| rime.imageRegistryServer.imageRegistryJob.serviceAccount.annotations."eks.amazonaws.com/role-arn" | string | `""` | Specify ARN of IRSA-enabled Image Builder IAM role here |
| rime.imageRegistryServer.serviceAccount.annotations."eks.amazonaws.com/role-arn" | string | `""` | Specify ARN of IRSA-enabled Repo Manager IAM role here |
| rime.images | object | `{"backendImage":{"name":"robustintelligencehq/rime-backend:latest","pullPolicy":"Always","registry":"docker.io"},"frontendImage":{"name":"robustintelligencehq/rime-frontend:latest","pullPolicy":"Always","registry":"docker.io"},"imageBuilderImage":{"name":"robustintelligencehq/rime-image-builder:latest","pullPolicy":"Always","registry":"docker.io"},"imagePullSecrets":[{"name":"rimecreds"}],"kubectlImage":{"name":"robustintelligencehq/kubectl:v1.0","pullPolicy":"Always","registry":"docker.io"},"modelTestingImage":{"name":"robustintelligencehq/rime-testing-engine-dev:latest","pullPolicy":"Always","registry":"docker.io"}}` | Parameters for Robust Intelligence Docker images (update accordingly if using a private registry) |
| rime.ingress | object | (see individual values in `values.yaml`) | `ingress` K8s-level configurations |
| rime.initClusterMetadata | object | (see individual values in `values.yaml`) | `initClusterMetadata` K8s-level configurations |
| rime.initMongoTLS | object | (see individual values in `values.yaml`) | `initMongoTLS` K8s-level configurations |
| rime.internalAgent | object | `{"agentID":"","enabled":false,"registrationApiKey":{"k8sSecretName":"","keyPath":""}}` | internalAgent includes configuration for the internal agent attached to this control plane. This includes information to help the registration work properly. The internal agent is optional - it is not necessary when we are doing a split CP<>DP deployment It is a convenience thing for managed cloud and a full self-hosted deployment. |
| rime.internalWorkerJobs | object | `{"existingConfigSecretName":""}` | Settings shared across internal worker jobs (e.g., `drop-duplicates`, `init-indexes`) |
| rime.internalWorkerJobs.existingConfigSecretName | string | `""` | Use if MANUALLY creating a Secret to replace the default internal service configuration. NOTE: This Secret's schema MUST match that of the corresponding default defined in /templates/**/configmap.yaml. |
| rime.modelTestingServer | object | (see individual values in `values.yaml`) | `modelTestingServer` K8s-level configurations |
| rime.modelTestingServer.existingConfigSecretName | string | `""` | Use if MANUALLY creating a Secret to replace the default internal service configuration. NOTE: This Secret's schema MUST match that of the corresponding default defined in /templates/**/configmap.yaml. |
| rime.monitoring | object | (see individual values in `values.yaml`) | `monitoring` (Prometheus metrics/Datadog) K8s-level configurations |
| rime.monitoring.datadogEnabled | bool | `true` | Whether to enable Datadog autodiscovery tags for all services on the RIME cluster |
| rime.monitoring.enabled | bool | `true` | Whether to enable Prometheus metrics for all services on the RIME cluster |
| rime.monitoring.port | int | `8080` | Port to expose Prometheus metrics on |
| rime.notificationsWorker | object | (see individual values in `values.yaml`) | `notificationsWorker` K8s-level configurations |
| rime.notificationsWorker.existingConfigSecretName | string | `""` | Use if MANUALLY creating a Secret to replace the default internal service configuration. NOTE: This Secret's schema MUST match that of the corresponding default defined in /templates/**/configmap.yaml. |
| rime.notificationsWorker.notificationsDigestCron | object | `{"annotations":{},"enabled":true,"labels":{},"name":"notifications-digest-cron","schedule":"*/20 * * * *"}` | Configuration for scheduled push notifications |
| rime.rolloutRestart | object | (see individual values in `values.yaml`) | `rolloutRestart` K8s-level configurations |
| rime.scheduledSTCron | object | `{"annotations":{},"enabled":true,"labels":{},"name":"scheduled-st-cron","schedule":"*/20 * * * *"}` | Configuration for Scheduled Stress Testing |
| rime.secrets | object | (see individual values in `values`.yaml) | Values for the internal RIME K8 secret |
| rime.storageManagerServer | object | (see individual values in `values.yaml`) | `storageManagerServer` K8s-level configurations |
| rime.storageManagerServer.existingConfigSecretName | string | `""` | Use if MANUALLY creating a Secret to replace the default internal service configuration. NOTE: This Secret's schema MUST match that of the corresponding default defined in /templates/**/configmap.yaml. |
| rime.storageManagerServer.initVault.existingConfigSecretName | string | `""` | Use if MANUALLY creating a Secret to replace the default internal service configuration. NOTE: This Secret's schema MUST match that of the corresponding default defined in /templates/**/configmap.yaml. |
| rime.uploadServer | object | (see individual values in `values.yaml`) | `uploadServer` K8s-level configurations |
| rime.uploadServer.existingConfigSecretName | string | `""` | Use if MANUALLY creating a Secret to replace the default internal service configuration. NOTE: This Secret's schema MUST match that of the corresponding default defined in /templates/**/configmap.yaml. |
| rime.webServer | object | (see individual values in `values.yaml`) | `webServer` K8s-level configurations |
| rime.webServer.existingConfigSecretName | string | `""` | Use if MANUALLY creating a Secret to replace the default internal service configuration. NOTE: This Secret's schema MUST match that of the corresponding default defined in /templates/**/configmap.yaml. |
| tls.autorotateEnabled | bool | `false` | Whether to automatically rotate TLS certificates for services (`enableCertManager` must be true to enable) |
| tls.certificateSpec | object | `{"issuerRef":{"group":"cert-manager.io","kind":"Issuer","name":""},"subject":{"organizations":["RobustIntelligence"]}}` | `spec` for Certificate object (https://cert-manager.io/docs/usage/certificate/). |
| tls.certificateSpec.issuerRef | object | `{"group":"cert-manager.io","kind":"Issuer","name":""}` | See https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.CertificateSpec Attributes listed below are the minimum required for the `issuerRef` property. |
| tls.certificateSpec.issuerRef.name | string | `""` | Will default to `rime-{{ .Release.Namespace }}-ca-issuer`. |
| tls.certificateSpec.subject | object | `{"organizations":["RobustIntelligence"]}` | See https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.CertificateSpec Attributes listed below are the minimum required for the `subject` property. |
| tls.crossplaneEnabled | bool | `false` | Whether to enable mutual TLS for cross-plane (control plane to data plane) communications (`enableCertManager` must be true to enable) |
| tls.enableCertManager | bool | `false` | Whether to enable the cert-manager service for issuing and managing TLS certificates within the cluster |
| tls.grpcEnabled | bool | `false` | Whether to enable mutual TLS for REST communications (`enableCertManager` must be true to enable) TODO explain why this is here (I thought cluster internal was gRPC) |
| tls.mongoEnabled | bool | `false` | Whether to disable mutual TLS for the MongoDB service (`enableCertManager` must be true to enable) |
| tls.restEnabled | bool | `false` | Whether to enable mutual TLS for REST communications (`enableCertManager` must be true to enable) TODO explain why this is here (I thought cluster internal was gRPC) |
| tls.vaultDisabled | bool | `true` | Whether to disable mutual TLS for the Vault service (`enableCertManager` must be true to enable) |
| vault | object | (see individual values in `values`.yaml) | Vault sub-chart. See https://github.com/hashicorp/vault-helm for more information. |
| vault.global.tlsDisable | bool | `true` | Whether to disable mutual TLS for Vault. Must match `tls.vaultDisabled` |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
