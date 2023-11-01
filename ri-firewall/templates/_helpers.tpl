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
            generativeFirewallFileStorageServerAddr: "{{ include "ri-firewall.fullname" . }}-{{ .Values.riFirewall.fileStorageServer.name }}:{{ .Values.riFirewall.fileStorageServer.port }}"
    metrics:
        enabled: {{ .Values.riFirewall.monitoring.enabled }}
        port: {{ .Values.riFirewall.monitoring.port }}
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
Return the service account name used by the services that need blob storage.
The service account has read and write access to the S3 bucket used for the
blob storage.  If we are creating a service account, use the service name by
default. Otherwise allow the user to specify the service account name.
*/}}
{{- define "ri-firewall.fileStorageServer.serviceAccountName" -}}
{{ default (printf "%s-%s" (include "ri-firewall.fullname" .) .Values.riFirewall.fileStorageServer.name) .Values.riFirewall.fileStorageServer.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the service account name used by the config server.
*/}}
{{- define "ri-firewall.configServer.serviceAccountName" -}}
{{- if .Values.riFirewall.configServer.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "ri-firewall.fullname" .) .Values.riFirewall.configServer.name) .Values.riFirewall.configServer.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.riFirewall.configServer.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the name of the config map storing user configuration for the firewall.
For now, we are doing a one deployment <> one firewall scheme.
This is the deployment-wide configuration for the firewall.
It includes configuration like the URL for the fact sheet and the URL of the
sensitive terms path.
The config server writes to this and the firewall server consumes from it.
*/}}
{{- define "ri-firewall.firewallConfigMapName" -}}
    {{ include "ri-firewall.fullname" . }}-user-firewall-config
{{- end -}}

{{/*
Name for the ConfigMap containing the model name to address
mapping.
*/}}
{{- define "ri-firewall.modelConnectionConfigMapName" -}}
{{- printf "%s-model-connection-map-conf" (include "ri-firewall.fullname" .) }}
{{- end -}}

{{/*
Return the service account name used by the firewall server.
*/}}
{{- define "ri-firewall.firewallServer.serviceAccountName" -}}
{{ default (printf "%s-%s" (include "ri-firewall.fullname" .) .Values.riFirewall.firewallServer.name) .Values.riFirewall.firewallServer.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- end -}}
