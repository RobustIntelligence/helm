# rime-extras

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v9](https://img.shields.io/badge/AppVersion-v9-informational?style=flat-square)

A Helm chart for RIME's extra resources

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://helm.datadoghq.com | datadog | 3.32.8 |
| https://prometheus-community.github.io/helm-charts | prometheus | 25.6.0 |
| https://prometheus-community.github.io/helm-charts | prometheus-node-exporter | 4.22.0 |
| https://vmware-tanzu.github.io/helm-charts | velero | 2.23.6 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| datadog | object | (see individual values in `values`.yaml) | For full reference, see https://github.com/DataDog/helm-charts/tree/datadog-2.20.3/charts/datadog |
| datadog.datadog.apiKey | string | `""` | API key for DataDog services. Will be provided by your RI Solutions Architect. |
| datadog.datadog.env[0] | object | `{"name":"DD_LOGS_CONFIG_PROCESSING_RULES","value":"[{\n  \"type\": \"mask_sequences\",\n  \"name\": \"mask_ip\",\n  \"replace_placeholder\": \"[masked_ip]\",\n  \"pattern\" : \"(?:[0-9]{1,3}\\\\.){3}[0-9]{1,3}\"\n },\n {\n  \"type\": \"mask_sequences\",\n  \"name\": \"mask_email\",\n  \"replace_placeholder\": \"[masked_email]\",\n  \"pattern\" : \"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\\\.[a-zA-Z]{2,4}\"\n }]"}` | Log masking to prevent transmission of sensitive info NOTE: regex in the log rules require an extra escape for any escape character used, e.g. \\\b for \b in normal regex |
| datadog.datadog.tags | list | `["user:${datadog_user_tag}","rime-version:${datadog_rime_version_tag}"]` | List of static tags to attach to every metric, event and service check collected by this Agent.  Learn more about tagging: https://docs.datadoghq.com/tagging/ |
| observabilityProxyServer.containerPort | int | `8000` |  |
| observabilityProxyServer.image.name | string | `"robustintelligencehq/observability-proxy-server:v0.1"` |  |
| observabilityProxyServer.image.pullPolicy | string | `"Always"` |  |
| observabilityProxyServer.image.registry | string | `"docker.io"` |  |
| observabilityProxyServer.port | int | `8000` |  |
| prometheus-node-exporter | object | (see individual values in `values`.yaml) | For full reference, see https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-node-exporter |
| prometheus.alertmanager.enabled | bool | `false` |  |
| prometheus.kube-state-metrics.enabled | bool | `true` |  |
| prometheus.kube-state-metrics.image.registry | string | `"docker.io"` |  |
| prometheus.kube-state-metrics.image.repository | string | `"robustintelligencehq/kube-state-metrics"` |  |
| prometheus.kube-state-metrics.image.tag | string | `"v2.10.1"` |  |
| prometheus.prometheus-node-exporter.enabled | bool | `false` |  |
| prometheus.prometheus-pushgateway.enabled | bool | `false` |  |
| prometheus.server.defaultFlagsOverride[0] | string | `"--config.file=/etc/config/prometheus.yml"` |  |
| prometheus.server.image.pullPolicy | string | `"Always"` |  |
| prometheus.server.image.registry | string | `"docker.io"` |  |
| prometheus.server.image.repository | string | `"robustintelligencehq/prometheus"` |  |
| prometheus.server.image.tag | string | `"v2.48.0"` |  |
| prometheus.server.persistentVolume.enabled | bool | `false` |  |
| prometheus.server.remoteWrite[0].url | string | `"http://observability-proxy-server:8000/remote_write"` |  |
| rimeExtras.datadog | bool | `false` | Whether to install the DataDog Helm charts for observability |
| rimeExtras.observabilityProxyServer | bool | `false` | Whether to install the Observability Proxy Server Helm charts for observability |
| rimeExtras.prometheusNodeExporter | bool | `false` | Whether to install the Prometheus Node Exporter Helm charts for observability |
| rimeExtras.prometheusServer | bool | `false` | Whether to install the Prometheus Server Helm charts for observability |
| rimeExtras.velero | bool | `false` | Whether to install the Velero Helm charts for disaster recovery |
| velero | object | (see individual values in `values`.yaml) | For full reference, see https://github.com/vmware-tanzu/helm-charts/tree/velero-2.23.6/charts/velero |
| velero.configuration.backupStorageLocation.bucket | string | `""` | Bucket is the name of the bucket to store backups in. Required. |
| velero.configuration.backupStorageLocation.config.region | string | `""` | AWS region for the EKS cluster |
| velero.configuration.volumeSnapshotLocation.config.region | string | `""` | AWS region for the EKS cluster |
| velero.configuration.volumeSnapshotLocation.name | string | `"mongodb-snapshots"` | Name of the volume snapshot location where snapshots are being taken. Required. |
| velero.initContainers | list | `[{"image":"docker.io/robustintelligencehq/velero-plugin-for-aws:v1.2.1","imagePullPolicy":"IfNotPresent","name":"velero-plugin-for-aws","volumeMounts":[{"mountPath":"/target","name":"plugins"}]}]` | Init containers to add to the Velero deployment's pod spec. At least one plugin provider image is required. For other cloud providers, see https://velero.io/docs/v1.6/supported-providers/ |
| velero.schedules.mongodb-backup.schedule | string | `"0 */4 * * *"` | Default: every four hours starting at 12:00 AM |
| velero.schedules.mongodb-backup.template.includedNamespaces | list | `["*"]` | At minimum, should include the RIME namespace(s) (all namespaces recommended) |
| velero.schedules.mongodb-backup.template.ttl | string | `"336h"` | Backup horizon. Default is 336h (i.e., 2 weeks) |
| velero.serviceAccount.annotations | object | `{"eks.amazonaws.com/role-arn":""}` | For AWS: Specify ARN of IRSA-enabled Velero Backups IAM role here |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
