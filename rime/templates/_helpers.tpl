{{/*
Expand the name of the chart.
*/}}
{{- define "rime.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rime.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
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
{{- define "rime.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common environment variables used in all RIME services.
*/}}
{{- define "rime.commonEnv" -}}
- name: RIME_JWT
  value: "{{ .Values.rimeJwt }}"
- name: RIME_CROSS_SERVICE_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "rime.fullname" . }}-secrets
      key: cross-service-key
{{- end }}

{{/*
RIME JWT secrets environment variable.
*/}}
{{- define "rime.rimeJwtSecret" -}}
- name: RIME_JWT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "rime.fullname" . }}-secrets
      key: jwt-secret
{{- end }}

{{/*
Web app host environmental variable used in our application code.
*/}}
{{- define "rime.webAppHostEnv" -}}
{{- if .Values.rime.webAppHostOverride }}
- name: RIME_WEB_APP_HOST
  value: .Values.rime.webAppHostOverride
{{- else }}
- name: RIME_WEB_APP_HOST
  value: "rime.{{ .Values.rime.domain }}"
{{- end }}
{{- end }}

{{/*
Environment variable to be used in Model Testing Job Template container configuration for upload server address.
The agent must provide the configmap specifying this value when it launches the job.
*/}}
{{- define "rime.uploadServerEnv" -}}
- name: UPLOAD_SERVER
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.modelTesting.configMapName }}
      key: upload_server
{{- end }}

{{/*
Environment variable to be used in Model Testing Job Template container configuration for firewall server address.
The agent must provide the configmap specifying this value when it launches the job.
*/}}
{{- define "rime.firewallServerEnv" -}}
- name: FIREWALL_SERVER
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.modelTesting.configMapName }}
      key: firewall_server
{{- end }}

Environment variable to be used in Model Testing Job Template container configuration for data collector address.
The agent must provide the configmap specifying this value when it launches the job.
*/}}
{{- define "rime.dataCollectorEnv" -}}
- name: DATA_COLLECTOR
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.modelTesting.configMapName }}
      key: data_collector
{{- end }}

{{/*
Environment variable to be used in Model Testing Job Template container configuration for API key.
The agent must provide the configmap specifying this value when it launches the job.
*/}}
{{- define "rime.apiKeyEnv" -}}
- name: API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "rime.modelTesting.secretName" . }}
      key: api_key
{{- end }}

{{/*
Environment variable to be used in Model Testing Job Template container configuration for disabling TLS.
The agent must provide the configmap specifying this value when it launches the job.
The Rime Engine CLI reads `RIME_DISABLE_TLS` as the value for the `--disable_tls` flag.
TLS must be disabled for a internal agent and enabled otherwise.
*/}}
{{- define "rime.disableTLSEnv" -}}
- name: RIME_DISABLE_TLS
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.modelTesting.configMapName }}
      key: disable_tls
{{- end }}

{{/*
Common labels
*/}}
{{- define "rime.labels" -}}
helm.sh/chart: {{ include "rime.chart" . }}
{{ include "rime.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rime.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rime.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Prometheus scraping annotations that define where metrics are exposed.
*/}}
{{- define "prometheusScrapingAnnotations" -}}
{{- if .Values.prometheusMetricsExposition.enabled -}}
prometheus.io/scrape: "true"
prometheus.io/path: {{ .Values.prometheusMetricsExposition.path }}
prometheus.io/port: "{{ .Values.prometheusMetricsExposition.port }}"
{{- end -}}
{{- end -}}

{{/*
Return the service account name used by the image registry service to create new jobs
and to create, access, and modify image repositories.
*/}}
{{- define "imageRegistryServerAccount.name" -}}
{{- if and .Values.imageRegistry.rbac.create .Values.imageRegistry.rbac.serverAccount.create -}}
{{ include "rime.fullname" . }}-repo-manager
{{- else -}}
{{ .Values.imageRegistry.rbac.serverAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the service account name used by the image building jobs, which can
push images to the image repository.
*/}}
{{- define "imageRegistryJobAccount.name" -}}
{{- if and .Values.imageRegistry.rbac.create .Values.imageRegistry.rbac.jobAccount.create -}}
{{ include "rime.fullname" . }}-image-pusher
{{- else -}}
{{ .Values.imageRegistry.rbac.jobAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the service account name used by the model testing service
*/}}
{{- define "modelTesting.serviceAccountName" -}}
{{- if and .Values.modelTesting.rbac.create .Values.modelTesting.rbac.serviceAccount.create -}}
{{ include "rime.fullname" . }}-model-testing-service-account
{{- else -}}
{{ .Values.modelTesting.rbac.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the service account name used by the services that need blob storage.
The service account has read and write access to the S3 bucket used for the blob storage.
*/}}
{{- define "blobStoreAccount.name" -}}
{{- if and .Values.blobStore.rbac.create .Values.blobStore.rbac.blobStoreAccount.create -}}
{{ include "rime.fullname" . }}-blob-store
{{- else -}}
{{ .Values.blobStore.rbac.blobStoreAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Rime secrets name
*/}}
{{- define "rime.secrets" -}}
{{ include "rime.fullname" . }}-secrets
{{- end -}}

{{/*
Name of the secret the agent should use to inject secret values into model test jobs.
This name must be kept in sync between the agent and the control plane.
*/}}
{{- define "rime.modelTesting.secretName" -}}
rime-agent-model-testing-secret
{{- end }}
