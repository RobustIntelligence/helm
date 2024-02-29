# rime-extras

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v9](https://img.shields.io/badge/AppVersion-v9-informational?style=flat-square)

A Helm chart for RIME's extra resources

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://fluent.github.io/helm-charts | fluent-bit | 0.42.0 |
| https://helm.datadoghq.com | datadog | 3.32.8 |
| https://humio.github.io/humio-helm-charts | humio-helm-charts | 0.9.5 |
| https://prometheus-community.github.io/helm-charts | prometheus | 25.6.0 |
| https://prometheus-community.github.io/helm-charts | prometheus-cloudwatch-exporter | 0.25.2 |
| https://prometheus-community.github.io/helm-charts | prometheus-node-exporter | 4.22.0 |
| https://vmware-tanzu.github.io/helm-charts | velero | 2.23.6 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| datadog | object | (see individual values in `values`.yaml) | For full reference, see https://github.com/DataDog/helm-charts/tree/datadog-2.20.3/charts/datadog |
| datadog.datadog.apiKey | string | `""` | API key for DataDog services. Will be provided by your RI Solutions Architect. |
| datadog.datadog.env[0] | object | `{"name":"DD_LOGS_CONFIG_PROCESSING_RULES","value":"[{\n  \"type\": \"mask_sequences\",\n  \"name\": \"mask_ip\",\n  \"replace_placeholder\": \"[masked_ip]\",\n  \"pattern\" : \"(?:[0-9]{1,3}\\\\.){3}[0-9]{1,3}\"\n },\n {\n  \"type\": \"mask_sequences\",\n  \"name\": \"mask_email\",\n  \"replace_placeholder\": \"[masked_email]\",\n  \"pattern\" : \"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\\\.[a-zA-Z]{2,4}\"\n }]"}` | Log masking to prevent transmission of sensitive info NOTE: regex in the log rules require an extra escape for any escape character used, e.g. \\\b for \b in normal regex |
| datadog.datadog.tags | list | `["user:${datadog_user_tag}","rime-version:${datadog_rime_version_tag}"]` | List of static tags to attach to every metric, event and service check collected by this Agent.  Learn more about tagging: https://docs.datadoghq.com/tagging/ |
| fluent-bit.config.filters | string | `"[FILTER]\n  Name kubernetes\n  Match kube.*\n  Merge_Log On\n  Keep_Log Off\n  K8S-Logging.Parser On\n  K8S-Logging.Exclude On\n  Annotations Off\n  Labels Off\n  Buffer_Size 10MB\n\n[FILTER]\n  Name modify\n  Match *\n  Condition Key_does_not_exist attr.error.code\n  Rename attr.error attr.error_str\n\n[FILTER]\n  Name modify\n  Match *\n  Condition Key_exists message\n  Rename message msg\n\n[FILTER]\n  Name nest\n  Match kube.*\n  Operation lift\n  Nested_under kubernetes\n\n[FILTER]\n  Name modify\n  Match kube.*\n  Remove attr\n  Rename log msg\n"` |  |
| fluent-bit.config.inputs | string | `"[INPUT]\n  Name tail\n  Path /var/log/containers/*.log\n  multiline.parser docker, cri\n  Tag kube.*\n  Mem_Buf_Limit 10MB\n  Skip_Long_Lines On\n"` |  |
| fluent-bit.config.outputs | string | `"[OUTPUT]\n  Name opensearch\n  Match kube.*\n  Host search-ri-opensearch-vqycu6e5fafj4zojubom4zzl4y.us-west-2.es.amazonaws.com\n  Port 443\n  Index ri_logs.%Y.%m.%d\n  AWS_Auth On\n  AWS_Region us-west-2\n  AWS_Role_ARN arn:aws:iam::746181457053:role/fluentbit_role\n  Suppress_Type_Name On\n  TLS On\n  Trace_Error On\n"` |  |
| fluent-bit.config.service | string | `"[SERVICE]\n  Daemon Off\n  Flush {{ .Values.flush }}\n  Log_Level {{ .Values.logLevel }}\n  Parsers_File /fluent-bit/etc/parsers.conf\n  Parsers_File /fluent-bit/etc/conf/custom_parsers.conf\n  HTTP_Server On\n  HTTP_Listen 0.0.0.0\n  HTTP_Port {{ .Values.metricsPort }}\n  Health_Check On\n"` |  |
| fluent-bit.image.pullPolicy | string | `"IfNotPresent"` |  |
| fluent-bit.image.repository | string | `"docker.io/robustintelligencehq/fluent-bit"` |  |
| fluent-bit.image.tag | string | `"2.2.2"` |  |
| fluent-bit.imagePullSecrets[0].name | string | `"rimecreds"` |  |
| fluent-bit.nameOverride | string | `"ri-observability-fluent-bit"` |  |
| fluent-bit.tolerations[0].effect | string | `"NoSchedule"` |  |
| fluent-bit.tolerations[0].operator | string | `"Exists"` |  |
| humio-helm-charts | object | (see individual values in `values`.yaml) | For full reference, see https://github.com/humio/humio-helm-charts/tree/release-0.9.5/charts/humio-fluentbit |
| observabilityProxyServer.containerPort | int | `8000` |  |
| observabilityProxyServer.image.name | string | `"robustintelligencehq/observability-proxy-server:v0.1"` |  |
| observabilityProxyServer.image.pullPolicy | string | `"IfNotPresent"` |  |
| observabilityProxyServer.image.registry | string | `"docker.io"` |  |
| observabilityProxyServer.port | int | `8000` |  |
| observabilityProxyServer.remoteWriteSecretName | string | `"remote-write-api-key"` |  |
| observabilityProxyServer.remoteWriteURL | string | `"https://4dj9f20xee.execute-api.us-west-2.amazonaws.com/production/remote_write"` |  |
| prometheus-cloudwatch-exporter.config | string | `"region: \"us-west-2\"\nperiod_seconds: 60\ndelay_seconds: 900\nmetrics:\n\n- aws_metric_name: CPUUtilization\n  aws_namespace: AWS/EC2\n  aws_statistics:\n  - Average\n  aws_dimensions:\n  - InstanceId\n\n# The number of unhealthy hosts\n- aws_metric_name: UnHealthyHostCount\n  aws_namespace: AWS/ELB\n  aws_statistics:\n  - Minimum\n  aws_dimensions:\n  - LoadBalancerName\n  - AvailabilityZone\n\n# The total number of bytes processed by the load balancer, including TCP/IP headers.\n# This count includes traffic to and from targets, minus health check traffic.\n- aws_metric_name: ProcessedBytes\n  aws_namespace: AWS/NetworkELB\n  aws_statistics:\n  - Sum\n  aws_dimensions:\n  - LoadBalancer\n  - AvailabilityZone\n\n# The total number of concurrent flows (or connections) from clients to targets.\n- aws_metric_name: ActiveFlowCount\n  aws_namespace: AWS/NetworkELB\n  aws_statistics:\n  - Average\n  aws_dimensions:\n  - LoadBalancer\n  - AvailabilityZone\n\n# The number of new ICMP messages rejected by the inbound rules of the load balancer security groups.\n- aws_metric_name: SecurityGroupBlockedFlowCount_Inbound_ICMP\n  aws_namespace: AWS/NetworkELB\n  aws_statistics:\n  - Sum\n  aws_dimensions:\n  - LoadBalancer\n  - AvailabilityZone\n\n# The number of new TCP messages rejected by the inbound rules of the load balancer security groups.\n- aws_metric_name: SecurityGroupBlockedFlowCount_Inbound_TCP\n  aws_namespace: AWS/NetworkELB\n  aws_statistics:\n  - Sum\n  aws_dimensions:\n  - LoadBalancer\n  - AvailabilityZone\n\n# The number of new UDP messages rejected by the inbound rules of the load balancer security groups.\n- aws_metric_name: SecurityGroupBlockedFlowCount_Inbound_UDP\n  aws_namespace: AWS/NetworkELB\n  aws_statistics:\n  - Sum\n  aws_dimensions:\n  - LoadBalancer\n  - AvailabilityZone"` |  |
| prometheus-cloudwatch-exporter.image.pullPolicy | string | `"IfNotPresent"` |  |
| prometheus-cloudwatch-exporter.image.repository | string | `"docker.io/robustintelligencehq/cloudwatch-exporter"` |  |
| prometheus-cloudwatch-exporter.image.tag | string | `"v0.15.5"` |  |
| prometheus-cloudwatch-exporter.pod.annotations."app.kubernetes.io/owned-by" | string | `"ri"` |  |
| prometheus-cloudwatch-exporter.pod.annotations."prometheus.io/path" | string | `"/metrics"` |  |
| prometheus-cloudwatch-exporter.pod.annotations."prometheus.io/port" | string | `"9106"` |  |
| prometheus-cloudwatch-exporter.pod.annotations."prometheus.io/scrape" | string | `"true"` |  |
| prometheus-node-exporter | object | (see individual values in `values`.yaml) | For full reference, see https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-node-exporter |
| prometheus.alertmanager.enabled | bool | `false` |  |
| prometheus.configmapReload.prometheus.enabled | bool | `true` |  |
| prometheus.configmapReload.prometheus.image.pullPolicy | string | `"IfNotPresent"` |  |
| prometheus.configmapReload.prometheus.image.repository | string | `"docker.io/robustintelligencehq/prometheus-config-reloader"` |  |
| prometheus.configmapReload.prometheus.image.tag | string | `"v0.70.0"` |  |
| prometheus.kube-state-metrics.enabled | bool | `true` |  |
| prometheus.kube-state-metrics.image.registry | string | `"docker.io"` |  |
| prometheus.kube-state-metrics.image.repository | string | `"robustintelligencehq/kube-state-metrics"` |  |
| prometheus.kube-state-metrics.image.tag | string | `"v2.10.1"` |  |
| prometheus.kube-state-metrics.podAnnotations."app.kubernetes.io/owned-by" | string | `"ri"` |  |
| prometheus.kube-state-metrics.podAnnotations."prometheus.io/path" | string | `"/metrics"` |  |
| prometheus.kube-state-metrics.podAnnotations."prometheus.io/port" | string | `"8080"` |  |
| prometheus.kube-state-metrics.podAnnotations."prometheus.io/scrape" | string | `"true"` |  |
| prometheus.prometheus-node-exporter.enabled | bool | `false` |  |
| prometheus.prometheus-pushgateway.enabled | bool | `false` |  |
| prometheus.server.defaultFlagsOverride[0] | string | `"--web.enable-lifecycle"` |  |
| prometheus.server.defaultFlagsOverride[1] | string | `"--config.file=/etc/config/prometheus.yml"` |  |
| prometheus.server.global.scrape_interval | string | `"30s"` |  |
| prometheus.server.image.pullPolicy | string | `"IfNotPresent"` |  |
| prometheus.server.image.repository | string | `"docker.io/robustintelligencehq/prometheus"` |  |
| prometheus.server.image.tag | string | `"v2.48.0"` |  |
| prometheus.server.persistentVolume.enabled | bool | `false` |  |
| prometheus.server.remoteWrite[0].url | string | `"http://observability-proxy-server:8000/remote_write"` |  |
| prometheus.serverFiles."alerting_rules.yml" | object | `{}` |  |
| prometheus.serverFiles."prometheus.yml".rule_files[0] | string | `"/etc/config/recording_rules.yml"` |  |
| prometheus.serverFiles."prometheus.yml".rule_files[1] | string | `"/etc/config/alerting_rules.yml"` |  |
| prometheus.serverFiles."prometheus.yml".rule_files[2] | string | `"/etc/config/rules"` |  |
| prometheus.serverFiles."prometheus.yml".rule_files[3] | string | `"/etc/config/alerts"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[0].job_name | string | `"prometheus"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[0].static_configs[0].targets[0] | string | `"localhost:9090"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].bearer_token_file | string | `"/var/run/secrets/kubernetes.io/serviceaccount/token"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].job_name | string | `"kubernetes-apiservers"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].kubernetes_sd_configs[0].role | string | `"endpoints"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].relabel_configs[0].action | string | `"keep"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].relabel_configs[0].regex | string | `"default;kubernetes;https"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].relabel_configs[0].source_labels[0] | string | `"__meta_kubernetes_namespace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].relabel_configs[0].source_labels[1] | string | `"__meta_kubernetes_service_name"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].relabel_configs[0].source_labels[2] | string | `"__meta_kubernetes_endpoint_port_name"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].scheme | string | `"https"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].tls_config.ca_file | string | `"/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].tls_config.insecure_skip_verify | bool | `true` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].bearer_token_file | string | `"/var/run/secrets/kubernetes.io/serviceaccount/token"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].job_name | string | `"kubernetes-nodes"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].kubernetes_sd_configs[0].role | string | `"node"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[0].action | string | `"labelmap"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[0].regex | string | `"__meta_kubernetes_node_label_(.+)"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[1].replacement | string | `"kubernetes.default.svc:443"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[1].target_label | string | `"__address__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[2].regex | string | `"(.+)"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[2].replacement | string | `"/api/v1/nodes/$1/proxy/metrics"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[2].source_labels[0] | string | `"__meta_kubernetes_node_name"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[2].target_label | string | `"__metrics_path__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].scheme | string | `"https"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].tls_config.ca_file | string | `"/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].tls_config.insecure_skip_verify | bool | `true` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].bearer_token_file | string | `"/var/run/secrets/kubernetes.io/serviceaccount/token"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].job_name | string | `"kubernetes-nodes-cadvisor"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].kubernetes_sd_configs[0].role | string | `"node"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[0].action | string | `"labelmap"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[0].regex | string | `"__meta_kubernetes_node_label_(.+)"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[1].replacement | string | `"kubernetes.default.svc:443"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[1].target_label | string | `"__address__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[2].regex | string | `"(.+)"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[2].replacement | string | `"/api/v1/nodes/$1/proxy/metrics/cadvisor"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[2].source_labels[0] | string | `"__meta_kubernetes_node_name"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[2].target_label | string | `"__metrics_path__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].scheme | string | `"https"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].tls_config.ca_file | string | `"/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].tls_config.insecure_skip_verify | bool | `true` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].honor_labels | bool | `true` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].job_name | string | `"kubernetes-pods"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].kubernetes_sd_configs[0].role | string | `"pod"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[0].action | string | `"keep"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[0].regex | bool | `true` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[0].source_labels[0] | string | `"__meta_kubernetes_pod_annotation_prometheus_io_scrape"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[10].action | string | `"drop"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[10].regex | string | `"Pending|Succeeded|Failed|Completed"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[10].source_labels[0] | string | `"__meta_kubernetes_pod_phase"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[11].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[11].source_labels[0] | string | `"__meta_kubernetes_pod_node_name"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[11].target_label | string | `"node"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[1].action | string | `"keep"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[1].regex | string | `"ri"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[1].source_labels[0] | string | `"__meta_kubernetes_pod_annotation_app_kubernetes_io_owned_by"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[2].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[2].regex | string | `"(https?)"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[2].source_labels[0] | string | `"__meta_kubernetes_pod_annotation_prometheus_io_scheme"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[2].target_label | string | `"__scheme__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[3].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[3].regex | string | `"(.+)"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[3].source_labels[0] | string | `"__meta_kubernetes_pod_annotation_prometheus_io_path"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[3].target_label | string | `"__metrics_path__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[4].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[4].regex | string | `"(\\d+);(([A-Fa-f0-9]{1,4}::?){1,7}[A-Fa-f0-9]{1,4})"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[4].replacement | string | `"[$2]:$1"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[4].source_labels[0] | string | `"__meta_kubernetes_pod_annotation_prometheus_io_port"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[4].source_labels[1] | string | `"__meta_kubernetes_pod_ip"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[4].target_label | string | `"__address__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[5].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[5].regex | string | `"(\\d+);((([0-9]+?)(\\.|$)){4})"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[5].replacement | string | `"$2:$1"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[5].source_labels[0] | string | `"__meta_kubernetes_pod_annotation_prometheus_io_port"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[5].source_labels[1] | string | `"__meta_kubernetes_pod_ip"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[5].target_label | string | `"__address__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[6].action | string | `"labelmap"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[6].regex | string | `"__meta_kubernetes_pod_annotation_prometheus_io_param_(.+)"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[6].replacement | string | `"__param_$1"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[7].action | string | `"labelmap"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[7].regex | string | `"__meta_kubernetes_pod_label_(.+)"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[8].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[8].source_labels[0] | string | `"__meta_kubernetes_namespace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[8].target_label | string | `"namespace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[9].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[9].source_labels[0] | string | `"__meta_kubernetes_pod_name"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[9].target_label | string | `"pod"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[5].honor_labels | bool | `true` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[5].job_name | string | `"aws-node"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[5].kubernetes_sd_configs[0].role | string | `"pod"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[5].relabel_configs[0].action | string | `"keep"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[5].relabel_configs[0].regex | string | `"aws-vpc-cni"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[5].relabel_configs[0].source_labels[0] | string | `"__meta_kubernetes_pod_label_app_kubernetes_io_instance"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[5].relabel_configs[1].action | string | `"keep"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[5].relabel_configs[1].regex | bool | `true` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[5].relabel_configs[1].source_labels[0] | string | `"__meta_kubernetes_pod_annotation_prometheus_io_scrape"` |  |
| prometheus.serverFiles."recording_rules.yml" | object | `{}` |  |
| prometheus.serverFiles.alerts | object | `{}` |  |
| prometheus.serverFiles.rules | object | `{}` |  |
| rimeExtras.datadog | bool | `false` | Whether to install the DataDog Helm charts for observability |
| rimeExtras.humioFluentBit | bool | `false` | Whether to install the Humio FluentBit Helm charts for sending Firewall validation logs to Humio(Crowdstrike) for SIEM. |
| rimeExtras.observabilityProxyServer | bool | `false` | Whether to install the Observability Proxy Server Helm charts for observability |
| rimeExtras.prometheusCloudwatchExporter | bool | `false` | Whether to install the Prometheus CloudWatch Exporter Helm charts for observability |
| rimeExtras.prometheusNodeExporter | bool | `false` | Whether to install the Prometheus Node Exporter Helm charts for observability |
| rimeExtras.prometheusServer | bool | `false` | Whether to install the Prometheus Server Helm charts for observability |
| rimeExtras.riObservabilityFluentBit | bool | `false` | Whether to install the RI Observability FluentBit Helm chart for internal oversvability and monitoring |
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
