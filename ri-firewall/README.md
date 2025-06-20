# ri-firewall

![Version: 0.1.5](https://img.shields.io/badge/Version-0.1.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.18.0](https://img.shields.io/badge/AppVersion-0.18.0-informational?style=flat-square)

A Helm chart for the Robust Intelligence Firewall.

## Requirements

Kubernetes: `>=1.20.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://kubernetes.github.io/ingress-nginx | ingress-nginx | 4.12.1 |
| oci://registry-1.docker.io/bitnamicharts | valkey | 2.4.3 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ingress-nginx | object | (see individual values in `values`.yaml) | Ingress-nginx controller sub-chart. See https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx for all parameters. |
| ingress-nginx.controller.scope.namespace | string | `""` | K8s namespace for the ingress |
| ingress-nginx.controller.service.annotations | object | `{"service.beta.kubernetes.io/aws-load-balancer-healthcheck-path":"/healthz","service.beta.kubernetes.io/aws-load-balancer-healthcheck-port":80,"service.beta.kubernetes.io/aws-load-balancer-healthcheck-protocol":"http","service.beta.kubernetes.io/aws-load-balancer-proxy-protocol":"*","service.beta.kubernetes.io/aws-load-balancer-target-group-attributes":"preserve_client_ip.enabled=true"}` | For full list of annotations, see https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/service/annotations/ |
| riFirewall.authServer | object | (see individual values in `values.yaml`) | `authServer` K8s-level configurations |
| riFirewall.commonAnnotations | object | `{}` |  |
| riFirewall.commonLabels | object | `{}` |  |
| riFirewall.detectionEngineDeployment.configRepoURL | string | `"https://api.github.com/repos/RobustIntelligence/rime"` |  |
| riFirewall.detectionEngineDeployment.enabled | bool | `false` |  |
| riFirewall.detectionEngineDeployment.githubAppID | string | `"989224"` |  |
| riFirewall.detectionEngineDeployment.githubInstallationID | string | `"54537739"` |  |
| riFirewall.detectionEngineDeployment.githubPrivateKeyPEM | string | `""` |  |
| riFirewall.firewallInstanceConfigs | string | `nil` |  |
| riFirewall.firewallInstanceResourceQuota | object | `{"enabled":true,"maxObjectCount":15}` | firewallInstanceResourceQuota is configuration for a resource quota to limit the number of FirewallInstances a user can create in this deployment. |
| riFirewall.firewallLicenseLimits | object | `{"firewallInstances":10,"validateRequestsPerDay":500000}` | firewallLicenseLimits defines the usage limits for the firewall deployment. |
| riFirewall.firewallSystemConfig | object | `{"azureOpenaiModelProvider":{"apiBaseURL":"","apiVersion":"","chatModelDeploymentName":"","enabled":false},"enableHotfixYara":true,"maxRequestTokens":4096,"requireYaraPrefilter":false,"validateResponseVisibilitySettings":{"firewallRequestVisibility":{"enableApiResponse":false,"enableStdoutLogging":false},"ruleEvalMetadataVisibility":{"enableApiResponse":false,"enableStdoutLogging":true}}}` | firewallSystemConfig is system configuration for the RI Firewall. |
| riFirewall.firewallSystemConfig.validateResponseVisibilitySettings | object | `{"firewallRequestVisibility":{"enableApiResponse":false,"enableStdoutLogging":false},"ruleEvalMetadataVisibility":{"enableApiResponse":false,"enableStdoutLogging":true}}` | validateResponseVisibilitySettings control how different parts of the Validate response are output in the logs or the API response. This controls sensitive data such as internal rule evaluation or RAW USER DATA. Be careful with this setting. |
| riFirewall.hotfixYaraServer | object | (see individual values in `values.yaml`) | `yaraServer` K8s-level configurations |
| riFirewall.images | object | (see individual values in `values.yaml`) | Image specification for the RI Firewall. |
| riFirewall.ingress | object | (see individual values in `values.yaml`) | `ingress` K8s-level configurations |
| riFirewall.instanceManagerServer | object | (see individual values in `values.yaml`) | `instanceManagerServer` K8s-level configurations |
| riFirewall.modelServers.deployment.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchLabels.service-type | string | `"model-server"` |  |
| riFirewall.modelServers.deployment.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"topology.kubernetes.io/zone"` |  |
| riFirewall.modelServers.deployment.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `100` |  |
| riFirewall.modelServers.deployment.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].podAffinityTerm.labelSelector.matchLabels.service-type | string | `"model-server"` |  |
| riFirewall.modelServers.deployment.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` |  |
| riFirewall.modelServers.deployment.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].weight | int | `99` |  |
| riFirewall.modelServers.deployment.tolerations[0].effect | string | `"NoSchedule"` |  |
| riFirewall.modelServers.deployment.tolerations[0].key | string | `"dedicated"` |  |
| riFirewall.modelServers.deployment.tolerations[0].operator | string | `"Equal"` |  |
| riFirewall.modelServers.deployment.tolerations[0].value | string | `"dps"` |  |
| riFirewall.modelServers.deployment.topologySpreadConstraints[0].labelSelector.matchLabels.service-type | string | `"model-server"` |  |
| riFirewall.modelServers.deployment.topologySpreadConstraints[0].maxSkew | int | `1` |  |
| riFirewall.modelServers.deployment.topologySpreadConstraints[0].topologyKey | string | `"topology.kubernetes.io/zone"` |  |
| riFirewall.modelServers.deployment.topologySpreadConstraints[0].whenUnsatisfiable | string | `"ScheduleAnyway"` |  |
| riFirewall.modelServers.pdb.minAvailable | int | `1` |  |
| riFirewall.modelServers.promptInjectionBinary.remoteModelServerAddress | string | `""` |  |
| riFirewall.modelServers.promptInjectionBinary.resources.limits.cpu | string | `"5000m"` |  |
| riFirewall.modelServers.promptInjectionBinary.resources.limits.gpu | int | `0` |  |
| riFirewall.modelServers.promptInjectionBinary.resources.limits.memory | string | `"5000Mi"` |  |
| riFirewall.modelServers.promptInjectionBinary.resources.max_replicas | int | `3` |  |
| riFirewall.modelServers.promptInjectionBinary.resources.min_replicas | int | `1` |  |
| riFirewall.modelServers.promptInjectionBinary.resources.requests.cpu | string | `"1000m"` |  |
| riFirewall.modelServers.promptInjectionBinary.resources.requests.gpu | int | `0` |  |
| riFirewall.modelServers.promptInjectionBinary.resources.requests.memory | string | `"5000Mi"` |  |
| riFirewall.modelServers.promptInjectionBinary.useCachedArtifact.dockerImageOverride.name | string | `"robustintelligencehq/firewall-model-server-prompt-injection-binary:latest"` |  |
| riFirewall.modelServers.promptInjectionBinary.useCachedArtifact.dockerImageOverride.registry | string | `"docker.io"` |  |
| riFirewall.modelServers.promptInjectionBinary.useCachedArtifact.enabled | bool | `false` |  |
| riFirewall.modelServers.toxicity.remoteModelServerAddress | string | `""` |  |
| riFirewall.modelServers.toxicity.resources.limits.cpu | string | `"5000m"` |  |
| riFirewall.modelServers.toxicity.resources.limits.gpu | int | `0` |  |
| riFirewall.modelServers.toxicity.resources.limits.memory | string | `"3500Mi"` |  |
| riFirewall.modelServers.toxicity.resources.max_replicas | int | `3` |  |
| riFirewall.modelServers.toxicity.resources.min_replicas | int | `1` |  |
| riFirewall.modelServers.toxicity.resources.requests.cpu | string | `"1000m"` |  |
| riFirewall.modelServers.toxicity.resources.requests.gpu | int | `0` |  |
| riFirewall.modelServers.toxicity.resources.requests.memory | string | `"3500Mi"` |  |
| riFirewall.modelServers.toxicity.useCachedArtifact.dockerImageOverride.name | string | `"robustintelligencehq/firewall-model-server-toxicity:latest"` |  |
| riFirewall.modelServers.toxicity.useCachedArtifact.dockerImageOverride.registry | string | `"docker.io"` |  |
| riFirewall.modelServers.toxicity.useCachedArtifact.enabled | bool | `false` |  |
| riFirewall.modelServers.toxicityIntentMultiLabel.remoteModelServerAddress | string | `""` |  |
| riFirewall.modelServers.toxicityIntentMultiLabel.resources.limits.cpu | string | `"5000m"` |  |
| riFirewall.modelServers.toxicityIntentMultiLabel.resources.limits.gpu | int | `0` |  |
| riFirewall.modelServers.toxicityIntentMultiLabel.resources.limits.memory | string | `"1700Mi"` |  |
| riFirewall.modelServers.toxicityIntentMultiLabel.resources.max_replicas | int | `3` |  |
| riFirewall.modelServers.toxicityIntentMultiLabel.resources.min_replicas | int | `1` |  |
| riFirewall.modelServers.toxicityIntentMultiLabel.resources.requests.cpu | string | `"1000m"` |  |
| riFirewall.modelServers.toxicityIntentMultiLabel.resources.requests.gpu | int | `0` |  |
| riFirewall.modelServers.toxicityIntentMultiLabel.resources.requests.memory | string | `"1700Mi"` |  |
| riFirewall.modelServers.toxicityIntentMultiLabel.useCachedArtifact.dockerImageOverride.name | string | `"robustintelligencehq/firewall-model-server-toxicity-intent-multi-label:latest"` |  |
| riFirewall.modelServers.toxicityIntentMultiLabel.useCachedArtifact.dockerImageOverride.registry | string | `"docker.io"` |  |
| riFirewall.modelServers.toxicityIntentMultiLabel.useCachedArtifact.enabled | bool | `false` |  |
| riFirewall.modelServers.xlmMultilingualHarmful.remoteModelServerAddress | string | `""` |  |
| riFirewall.modelServers.xlmMultilingualHarmful.resources.limits.cpu | string | `"5000m"` |  |
| riFirewall.modelServers.xlmMultilingualHarmful.resources.limits.gpu | int | `0` |  |
| riFirewall.modelServers.xlmMultilingualHarmful.resources.limits.memory | string | `"3500Mi"` |  |
| riFirewall.modelServers.xlmMultilingualHarmful.resources.max_replicas | int | `3` |  |
| riFirewall.modelServers.xlmMultilingualHarmful.resources.min_replicas | int | `1` |  |
| riFirewall.modelServers.xlmMultilingualHarmful.resources.requests.cpu | string | `"1000m"` |  |
| riFirewall.modelServers.xlmMultilingualHarmful.resources.requests.gpu | int | `0` |  |
| riFirewall.modelServers.xlmMultilingualHarmful.resources.requests.memory | string | `"3500Mi"` |  |
| riFirewall.modelServers.xlmMultilingualHarmful.useCachedArtifact.dockerImageOverride.name | string | `"robustintelligencehq/firewall-model-server-xlm-multilingual-harmful:latest"` |  |
| riFirewall.modelServers.xlmMultilingualHarmful.useCachedArtifact.dockerImageOverride.registry | string | `"docker.io"` |  |
| riFirewall.modelServers.xlmMultilingualHarmful.useCachedArtifact.enabled | bool | `false` |  |
| riFirewall.modelServers.xlmMultilingualToxicity.remoteModelServerAddress | string | `""` |  |
| riFirewall.modelServers.xlmMultilingualToxicity.resources.limits.cpu | string | `"5000m"` |  |
| riFirewall.modelServers.xlmMultilingualToxicity.resources.limits.gpu | int | `0` |  |
| riFirewall.modelServers.xlmMultilingualToxicity.resources.limits.memory | string | `"3500Mi"` |  |
| riFirewall.modelServers.xlmMultilingualToxicity.resources.max_replicas | int | `3` |  |
| riFirewall.modelServers.xlmMultilingualToxicity.resources.min_replicas | int | `1` |  |
| riFirewall.modelServers.xlmMultilingualToxicity.resources.requests.cpu | string | `"1000m"` |  |
| riFirewall.modelServers.xlmMultilingualToxicity.resources.requests.gpu | int | `0` |  |
| riFirewall.modelServers.xlmMultilingualToxicity.resources.requests.memory | string | `"3500Mi"` |  |
| riFirewall.modelServers.xlmMultilingualToxicity.useCachedArtifact.dockerImageOverride.name | string | `"robustintelligencehq/firewall-model-server-xlm-multilingual-toxicity:latest"` |  |
| riFirewall.modelServers.xlmMultilingualToxicity.useCachedArtifact.dockerImageOverride.registry | string | `"docker.io"` |  |
| riFirewall.modelServers.xlmMultilingualToxicity.useCachedArtifact.enabled | bool | `false` |  |
| riFirewall.monitoring | object | (see individual values in `values.yaml`) | `monitoring` (Prometheus metrics/Datadog) K8s-level configurations |
| riFirewall.monitoring.enabled | bool | `true` | Whether to enable Prometheus metrics for all services on the Firewall |
| riFirewall.monitoring.port | int | `8080` | Port to expose Prometheus metrics on |
| riFirewall.operator | object | (see individual values in `values.yaml`) | `operator` K8s-level configurations The operator is responsible for reconciling FirewallInstance CRs. It creates individual firewall deployments and makes them available over the network. |
| riFirewall.piiAnalyzer | object | (see individual values in `values.yaml`) | `piiAnalyzer` K8s-level configurations |
| riFirewall.productionOptimizations | object | `{"overprovisionComputeNode":{"enabled":false,"poolSize":12},"overprovisionGPUNode":{"enabled":false,"poolSize":12,"resources":{"cpu":"1000m","memory":"3500Mi","nvidia.com/gpu":2}}}` | productionOptimizations defines optimizations for production deployments. |
| riFirewall.registerFirewallAgent.agentID | string | `""` |  |
| riFirewall.registerFirewallAgent.agentURL | string | `""` |  |
| riFirewall.registerFirewallAgent.apiKey | string | `""` |  |
| riFirewall.registerFirewallAgent.backoffLimit | int | `2` |  |
| riFirewall.registerFirewallAgent.enabled | bool | `false` |  |
| riFirewall.registerFirewallAgent.job.annotations | object | `{}` |  |
| riFirewall.registerFirewallAgent.job.labels | object | `{}` |  |
| riFirewall.registerFirewallAgent.job.resources.limits.memory | string | `"100Mi"` |  |
| riFirewall.registerFirewallAgent.job.resources.requests.cpu | string | `"100m"` |  |
| riFirewall.registerFirewallAgent.job.resources.requests.memory | string | `"100Mi"` |  |
| riFirewall.registerFirewallAgent.job.securityContext | object | `{}` |  |
| riFirewall.registerFirewallAgent.name | string | `"register-firewall-agent-job"` |  |
| riFirewall.registerFirewallAgent.platformAddress | string | `""` |  |
| riFirewall.registerFirewallAgent.registerVersion | string | `"0"` |  |
| riFirewall.registerFirewallAgent.serviceAccount.annotations | object | `{}` |  |
| riFirewall.registerFirewallAgent.serviceAccount.create | bool | `true` |  |
| riFirewall.registerFirewallAgent.serviceAccount.labels | object | `{}` |  |
| riFirewall.registerFirewallAgent.serviceAccount.name | string | `""` |  |
| riFirewall.rimeFirewallDeployment | object | `{"enabled":true}` | Whether to deploy rime-specific manifests for firewall. |
| riFirewall.secrets | object | (see individual values in `values`.yaml) | Values for the internal RI K8 secret used by the Firewall. |
| riFirewall.shimServer | object | (see individual values in `values.yaml`) | `shimServer` K8s-level configurations |
| riFirewall.tracing | object | (see individual values in `values.yaml`) | `tracing` (OpenTelemetry tracing) K8s-level configurations |
| riFirewall.tracing.enabled | bool | `true` | Whether to enable OpenTelemetry tracing for all services on the Firewall |
| riFirewall.yaraOperator.deployment.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"node_group"` |  |
| riFirewall.yaraOperator.deployment.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"In"` |  |
| riFirewall.yaraOperator.deployment.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] | string | `"dps"` |  |
| riFirewall.yaraOperator.deployment.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchLabels.app | string | `"yara-operator"` |  |
| riFirewall.yaraOperator.deployment.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey | string | `"topology.kubernetes.io/zone"` |  |
| riFirewall.yaraOperator.deployment.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight | int | `100` |  |
| riFirewall.yaraOperator.deployment.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].podAffinityTerm.labelSelector.matchLabels.app | string | `"yara-operator"` |  |
| riFirewall.yaraOperator.deployment.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].podAffinityTerm.topologyKey | string | `"kubernetes.io/hostname"` |  |
| riFirewall.yaraOperator.deployment.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[1].weight | int | `99` |  |
| riFirewall.yaraOperator.deployment.annotations | object | `{}` |  |
| riFirewall.yaraOperator.deployment.labels | object | `{}` |  |
| riFirewall.yaraOperator.deployment.replicaCount | int | `2` |  |
| riFirewall.yaraOperator.deployment.resources.limits.memory | string | `"300Mi"` |  |
| riFirewall.yaraOperator.deployment.resources.requests.cpu | string | `"10m"` |  |
| riFirewall.yaraOperator.deployment.resources.requests.memory | string | `"100Mi"` |  |
| riFirewall.yaraOperator.deployment.tolerations[0].effect | string | `"NoSchedule"` |  |
| riFirewall.yaraOperator.deployment.tolerations[0].key | string | `"dedicated"` |  |
| riFirewall.yaraOperator.deployment.tolerations[0].operator | string | `"Equal"` |  |
| riFirewall.yaraOperator.deployment.tolerations[0].value | string | `"dps"` |  |
| riFirewall.yaraOperator.deployment.topologySpreadConstraints[0].labelSelector.matchLabels.app | string | `"yara-operator"` |  |
| riFirewall.yaraOperator.deployment.topologySpreadConstraints[0].maxSkew | int | `1` |  |
| riFirewall.yaraOperator.deployment.topologySpreadConstraints[0].topologyKey | string | `"topology.kubernetes.io/zone"` |  |
| riFirewall.yaraOperator.deployment.topologySpreadConstraints[0].whenUnsatisfiable | string | `"ScheduleAnyway"` |  |
| riFirewall.yaraOperator.hpa.annotations | object | `{}` |  |
| riFirewall.yaraOperator.hpa.enabled | bool | `true` |  |
| riFirewall.yaraOperator.hpa.labels | object | `{}` |  |
| riFirewall.yaraOperator.hpa.maxReplicas | int | `3` |  |
| riFirewall.yaraOperator.hpa.metrics[0].resource.name | string | `"cpu"` |  |
| riFirewall.yaraOperator.hpa.metrics[0].resource.target.averageUtilization | int | `60` |  |
| riFirewall.yaraOperator.hpa.metrics[0].resource.target.type | string | `"Utilization"` |  |
| riFirewall.yaraOperator.hpa.metrics[0].type | string | `"Resource"` |  |
| riFirewall.yaraOperator.hpa.minReplicas | int | `2` |  |
| riFirewall.yaraOperator.name | string | `"yara-operator"` |  |
| riFirewall.yaraOperator.pdb.enabled | bool | `true` |  |
| riFirewall.yaraOperator.pdb.minAvailable | int | `1` |  |
| riFirewall.yaraOperator.serviceAccount.annotations | object | `{}` |  |
| riFirewall.yaraOperator.serviceAccount.create | bool | `true` |  |
| riFirewall.yaraOperator.serviceAccount.labels | object | `{}` |  |
| riFirewall.yaraOperator.serviceAccount.name | string | `nil` |  |
| riFirewall.yaraOperator.yaraServerTemplate.yaraServerImageRepo.name | string | `"robustintelligencehq/firewall-backend"` |  |
| riFirewall.yaraOperator.yaraServerTemplate.yaraServerImageRepo.registry | string | `"docker.io"` |  |
| valkey.enabled | bool | `false` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
