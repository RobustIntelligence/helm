# ri-firewall

![Version: 0.1.4](https://img.shields.io/badge/Version-0.1.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.18.0](https://img.shields.io/badge/AppVersion-0.18.0-informational?style=flat-square)

A Helm chart for the Robust Intelligence Firewall.

## Requirements

Kubernetes: `>=1.20.0-0`

| Repository | Name | Version |
|------------|------|---------|
| file://../ri-detection-resources | ri-detection-resources | 0.1.0 |
| https://kubernetes.github.io/ingress-nginx | ingress-nginx | 4.2.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ingress-nginx | object | (see individual values in `values`.yaml) | Ingress-nginx controller sub-chart. See https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx for all parameters. |
| ingress-nginx.controller.scope.namespace | string | `""` | K8s namespace for the ingress |
| ingress-nginx.controller.service.annotations | object | `{}` | For full list of annotations, see https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/service/annotations/ |
| ri-detection-resources | object | `{"modelServers":{"llmRejection":{"enabled":false}}}` | ri-detection-resources sub-chart This chart contains detection resources such as model servers and YARA servers. |
| riFirewall.authServer | object | (see individual values in `values.yaml`) | `authServer` K8s-level configurations |
| riFirewall.commonAnnotations | object | `{}` |  |
| riFirewall.commonLabels | object | `{}` |  |
| riFirewall.firewallInstanceResourceQuota | object | `{"enabled":true,"maxObjectCount":5}` | firewallInstanceResourceQuota is configuration for a resource quota to limit the number of FirewallInstances a user can create in this deployment. |
| riFirewall.firewallLicenseLimits | object | `{"firewallInstances":10,"validateRequestsPerDay":500000}` | firewallLicenseLimits defines the usage limits for the firewall deployment. |
| riFirewall.firewallSystemConfig | object | `{"azureOpenaiModelProvider":{"apiBaseURL":"","apiVersion":"","chatModelDeploymentName":"","enabled":false},"enableHotfixYara":true,"maxRequestTokens":8192,"validateResponseVisibilitySettings":{"firewallRequestVisibility":{"enableApiResponse":false,"enableStdoutLogging":false},"ruleEvalMetadataVisibility":{"enableApiResponse":false,"enableStdoutLogging":true}}}` | firewallSystemConfig is system configuration for the RI Firewall. |
| riFirewall.firewallSystemConfig.validateResponseVisibilitySettings | object | `{"firewallRequestVisibility":{"enableApiResponse":false,"enableStdoutLogging":false},"ruleEvalMetadataVisibility":{"enableApiResponse":false,"enableStdoutLogging":true}}` | validateResponseVisibilitySettings control how different parts of the Validate response are output in the logs or the API response. This controls sensitive data such as internal rule evaluation or RAW USER DATA. Be careful with this setting. |
| riFirewall.hotfixYaraServer | object | (see individual values in `values.yaml`) | `yaraServer` K8s-level configurations |
| riFirewall.images | object | (see individual values in `values.yaml`) | Image specification for the RI Firewall. |
| riFirewall.ingress | object | (see individual values in `values.yaml`) | `ingress` K8s-level configurations |
| riFirewall.instanceManagerServer | object | (see individual values in `values.yaml`) | `instanceManagerServer` K8s-level configurations |
| riFirewall.licenseServer | object | (see individual values in `values.yaml`) | `licenseServer` K8s-level configurations |
| riFirewall.monitoring | object | (see individual values in `values.yaml`) | `monitoring` (Prometheus metrics/Datadog) K8s-level configurations |
| riFirewall.monitoring.enabled | bool | `true` | Whether to enable Prometheus metrics for all services on the Firewall |
| riFirewall.monitoring.port | int | `8080` | Port to expose Prometheus metrics on |
| riFirewall.operator | object | (see individual values in `values.yaml`) | `operator` K8s-level configurations The operator is responsible for reconciling FirewallInstance CRs. It creates individual firewall deployments and makes them available over the network. |
| riFirewall.registerFirewallAgent.agentID | string | `""` |  |
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
| riFirewall.registerFirewallAgent.serviceAccount.annotations | object | `{}` |  |
| riFirewall.registerFirewallAgent.serviceAccount.create | bool | `true` |  |
| riFirewall.registerFirewallAgent.serviceAccount.labels | object | `{}` |  |
| riFirewall.registerFirewallAgent.serviceAccount.name | string | `""` |  |
| riFirewall.secrets | object | (see individual values in `values`.yaml) | Values for the internal RI K8 secret used by the Firewall. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
