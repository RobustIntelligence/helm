{{/*
Expand the name of the chart.
*/}}
{{- define "rime-agent.name" -}}
{{- default .Chart.Name .Values.rimeAgent.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rime-agent.fullname" -}}
{{- if .Values.rimeAgent.fullNameOverride }}
{{- .Values.rimeAgent.fullNameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.rimeAgent.nameOverride }}
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
{{- define "rime-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "rime-agent.labels" -}}
helm.sh/chart: {{ include "rime-agent.chart" . }}
{{ include "rime-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rime-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rime-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Return the name used for k8s Role granting job read access.
*/}}
{{- define "rime-agent.jobReaderRole.fullname" -}}
{{ include "rime-agent.fullname" . }}-job-reader
{{- end -}}

{{/*
Return the name used for k8s Role granting job write access.
*/}}
{{- define "rime-agent.jobWriterRole.fullname" -}}
{{ include "rime-agent.fullname" . }}-job-writer
{{- end -}}


{{/*
Return the app name for launcher.
*/}}
{{- define "rime-agent.launcher.appName" -}}
launcher
{{- end }}

{{/*
Return the full name used for launcher resources.
*/}}
{{- define "rime-agent.launcher.fullname" -}}
{{ include "rime-agent.fullname" . }}-{{ include "rime-agent.launcher.appName" . }}
{{- end -}}

{{/*
Create the name of the service account to use for Launcher
*/}}
{{- define "rime-agent.launcher.serviceAccountName" -}}
{{- if .Values.rimeAgent.launcher.serviceAccount.create -}}
    {{ default (include "rime-agent.launcher.fullname" .) .Values.rimeAgent.launcher.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.rimeAgent.launcher.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the app name for job monitor.
*/}}
{{- define "rime-agent.jobMonitor.appName" -}}
job-monitor
{{- end }}

{{/*
Return the name used for job monitor resources.
*/}}
{{- define "rime-agent.jobMonitor.fullname" -}}
{{ include "rime-agent.fullname" . }}-{{include "rime-agent.jobMonitor.appName" .}}
{{- end -}}

{{/*
Create the name of the service account to use for Job Monitor
*/}}
{{- define "rime-agent.jobMonitor.serviceAccountName" -}}
{{- if .Values.rimeAgent.launcher.serviceAccount.create -}}
    {{ default (include "rime-agent.jobMonitor.fullname" .) .Values.rimeAgent.jobMonitor.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.rimeAgent.jobMonitor.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
Return the service account name used by the model testing jobs, which has access to read S3 buckets.
*/}}
{{- define "rime-agent.modelTestJob.serviceAccountName" -}}
{{- if .Values.rimeAgent.modelTestJob.serviceAccount.create -}}
    {{ default "rime-agent-model-tester" .Values.rimeAgent.modelTestJob.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.rimeAgent.modelTestJob.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the name used for model testing job configmap. This must be in sync with the control plane.
*/}}
{{- define "rime-agent.modelTestJob.configMapName" -}}
{{ .Values.rimeAgent.modelTestJob.configMapName}}
{{- end -}}

{{/*
Return the name used for model testing job secret. This must be in sync with the control plane.
*/}}
{{- define "rime-agent.modelTestJob.secretName" -}}
rime-agent-model-testing-secret
{{- end -}}

{{/*
Return the name of the Secret containing the api key.
*/}}
{{- define "rime-agent.apiKeySecretName" -}}
{{ include "rime-agent.fullname" . }}-api-key
{{- end -}}

{{/*
Return the name of the created Secret containing docker config.
*/}}
{{- define "rime-agent.dockerSecretName" -}}
{{ include "rime-agent.fullname" . }}-docker
{{- end -}}

{{/*
Return image pull secrets to be used for all images (agent and model testing images).
*/}}
{{- define "rime-agent.imagePullSecretsYaml" -}}
{{- if (gt (len .Values.rimeAgent.imagePullSecrets) 0) -}}
{{ .Values.rimeAgent.imagePullSecrets | toYaml}}
{{- else -}}
- name : {{ include "rime-agent.dockerSecretName" . }}
{{- end -}}
{{- end -}}
