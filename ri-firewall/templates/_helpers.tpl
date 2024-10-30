{{/*
Expand the name of the chart.
*/}}
{{- define "ri-firewall.name" -}}
{{- default .Chart.Name .Values.riFirewall.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to
this (by the DNS naming spec). If release name contains chart name it will
be used as a full name.
*/}}
{{- define "ri-firewall.fullname" -}}
{{- if .Values.riFirewall.fullNameOverride }}
{{- .Values.riFirewall.fullNameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.riFirewall.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ri-firewall.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ri-firewall.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ri-firewall.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "ri-firewall.labels" -}}
helm.sh/chart: {{ include "ri-firewall.chart" . }}
{{ include "ri-firewall.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/part-of: {{ template "ri-firewall.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.riFirewall.commonLabels}}
{{ toYaml .Values.riFirewall.commonLabels }}
{{- end }}
{{- end -}}

{{/*
Common annotations added to all resources.
*/}}
{{- define "ri-firewall.annotations" -}}
helm.sh/chart: {{ include "ri-firewall.chart" . }}
{{ include "ri-firewall.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/part-of: {{ template "ri-firewall.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/owned-by: "ri"
{{- if .Values.riFirewall.commonAnnotations}}
{{ toYaml .Values.riFirewall.commonAnnotations }}
{{- end }}
{{- end -}}

{{/*
Return the name of the secret containing generated secrets used by the Firewall.
*/}}
{{- define "ri-firewall.generatedSecretsName" -}}
{{- printf "%s-generated-secrets" (include "ri-firewall.fullname" .) }}
{{- end }}

{{/*
Return the name of the existing secrets used by the Firewall.
*/}}
{{- define "ri-firewall.existingSecretsName" -}}
{{- printf "%s-existing-secrets" (include "ri-firewall.fullname" .) }}
{{- end }}

{{- define "ri-firewall.serverArgs" -}}
common:
    connections:
        addresses:
            generativeFirewallLicenseServerAddr: "{{ include "ri-firewall.fullname" . }}-{{ .Values.riFirewall.licenseServer.name }}:{{ .Values.riFirewall.licenseServer.port }}"
    metrics:
        enabled: {{ .Values.riFirewall.monitoring.enabled }}
        port: {{ .Values.riFirewall.monitoring.port }}
    tracing:
        enabled: {{ .Values.riFirewall.tracing.enabled }}
dataplane:
    agentID: {{ .Values.riFirewall.registerFirewallAgent.agentID }}
    platformAddress: {{ .Values.riFirewall.registerFirewallAgent.platformAddress }}
{{- end }}

{{/*
Return the appropriate apiVersion for Horizontal Pod Autoscaler.
*/}}
{{- define "ri-firewall.hpa.apiVersion" -}}
{{- if $.Capabilities.APIVersions.Has "autoscaling/v2/HorizontalPodAutoscaler" }}
{{- print "autoscaling/v2" }}
{{- else }}
{{- print "autoscaling/v2beta2" }}
{{- end }}
{{- end }}

{{/*
Return the service account name used by the firewall auth server.
*/}}
{{- define "ri-firewall.authServer.serviceAccountName" -}}
{{- if .Values.riFirewall.authServer.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "ri-firewall.fullname" .) .Values.riFirewall.authServer.name) .Values.riFirewall.authServer.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.riFirewall.authServer.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the service account name used by the firewall instance manager server.
*/}}
{{- define "ri-firewall.instanceManagerServer.serviceAccountName" -}}
{{- if .Values.riFirewall.instanceManagerServer.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "ri-firewall.fullname" .) .Values.riFirewall.instanceManagerServer.name) .Values.riFirewall.instanceManagerServer.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.riFirewall.instanceManagerServer.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the service account name used by the firewall instance operator.
*/}}
{{- define "ri-firewall.operator.serviceAccountName" -}}
{{- if .Values.riFirewall.operator.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "ri-firewall.fullname" .) .Values.riFirewall.operator.name) .Values.riFirewall.operator.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.riFirewall.operator.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the service account name used by the firewall license server.
*/}}
{{- define "ri-firewall.licenseServer.serviceAccountName" -}}
{{- if .Values.riFirewall.instanceManagerServer.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "ri-firewall.fullname" .) .Values.riFirewall.licenseServer.name) .Values.riFirewall.licenseServer.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.riFirewall.licenseServer.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the service account name used by register firewall agent job
*/}}
{{- define "ri-firewall.registerFirewallAgent.serviceAccountName" -}}
{{- if .Values.riFirewall.registerFirewallAgent.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "ri-firewall.fullname" .) .Values.riFirewall.registerFirewallAgent.name) .Values.riFirewall.registerFirewallAgent.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.riFirewall.registerFirewallAgent.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the name of the config map storing system configuration for the firewall,
such as the azure openAI base URL.
For now, we are doing a one deployment <> one firewall scheme.
This is the deployment-wide configuration for the firewall.
The firewall server consumes this configmap.
*/}}
{{- define "ri-firewall.firewallSystemConfigMapName" -}}
    {{ include "ri-firewall.fullname" . }}-system-firewall-config
{{- end -}}

{{/*
Name for the ConfigMap containing the model name to address
mapping.
Note: this ConfigMap is defined in the `ri-detection-resources` Helm chart, so this makes
an assumption about how that is created.
*/}}
{{- define "ri-firewall.modelConnectionConfigMapName" -}}
{{- printf "%s-ri-detection-resources-model-connection-map-conf" .Release.Name }}
{{- end -}}

{{/*
Address of the signal-gen YARA service for the firewall to connect to it.
Note: this service is defined in the `ri-detection-resources` Helm chart, so this makes
an assumption about how that name is determined as well as the port value.
*/}}
{{- define "ri-firewall.signalGenYaraServerAddr" -}}
{{- printf "%s-signalgen-yara:5025" .Release.Name }}
{{- end -}}
