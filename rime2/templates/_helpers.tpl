{{/*
Expand the name of the chart.
*/}}
{{- define "rime.name" -}}
{{- default .Release.Name .Values.rime.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rime.fullname" -}}
{{- if .Values.rime.fullnameOverride }}
{{- .Values.rime.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.rime.nameOverride }}
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
Selector labels
*/}}
{{- define "rime.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rime.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "rime.labels" -}}
helm.sh/chart: {{ include "rime.chart" . }}
{{ include "rime.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/part-of: {{ template "rime.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.rime.commonLabels}}
{{ toYaml .Values.rime.commonLabels }}
{{- end }}
{{- end -}}

{{/*
Common annotations
*/}}
{{- define "rime.annotations" -}}
helm.sh/chart: {{ include "rime.chart" . }}
{{ include "rime.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/part-of: {{ template "rime.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.rime.commonAnnotations}}
{{ toYaml .Values.rime.commonAnnotations }}
{{- end }}
{{- end -}}

{{/*
Common flags passed to all our servers. Be careful when modifying these values!
*/}}
{{- define "rime.serverArgs" -}}
common:
    mongo:
        url: "database-url={{ include "rime.fullname" . }}-mongodb-headless/?tls=false"
        prefix: "mongodb+srv://"
        replicaSetName: "{{ .Values.mongodb.replicaSetName }}"
    connections:
        featureFlagAddr: "{{ include "rime.fullname" . }}-{{.Values.rime.featureFlagServer.name}}:{{ .Values.rime.featureFlagServer.port }}"
        modelCardAddr: "{{ include "rime.fullname" . }}-{{.Values.rime.modelCardServer.name}}:{{ .Values.rime.modelCardServer.port }}"
        agentManagerAddr: "{{ include "rime.fullname" . }}-{{.Values.rime.agentManagerServer.name}}:{{ .Values.rime.agentManagerServer.port }}"
        dataCollectorAddr: "{{ include "rime.fullname" . }}-{{.Values.rime.dataCollectorServer.name}}:{{ .Values.rime.dataCollectorServer.port }}"
        firewallAddr: "{{ include "rime.fullname" . }}-{{.Values.rime.firewallServer.name}}:{{ .Values.rime.firewallServer.port }}"
        datasetManagerAddr: "{{ include "rime.fullname" . }}-{{.Values.rime.datasetManagerServer.name}}:{{ .Values.rime.datasetManagerServer.port }}"
    metrics:
        enabled: "{{ .Values.rime.monitoring.enabled }}"
        port: "{{ .Values.rime.monitoring.port }}"
    configuration:
        verbose: "{{ .Values.rime.verbose }}"
{{- end }}

{{/*
Return the service account name used by the services that need blob storage.
The service account has read and write access to the S3 bucket used for the blob storage.
*/}}
{{- define "blobStoreAccount.name" -}}
{{- if and .Values.rime.datasetManagerServer.blobStore.rbac.create .Values.rime.datasetManagerServer.blobStore.rbac.blobStoreAccount.create -}}
{{ include "rime.fullname" . }}-blob-store
{{- else -}}
{{ .Values.rime.datasetManagerServer.blobStore.rbac.blobStoreAccount.name }}
{{- end -}}
{{- end -}}

{{/*
JWT environmental variable used in our application code.
*/}}
{{- define "rime.jwtEnv" -}}
- name: RIME_JWT
  value: "{{ .Values.rime.rimeJwt }}"
{{- end }}

{{/*
JWT seceret environmental variable used in our application code.
*/}}
{{- define "rime.jwtSecretEnv" -}}
- name: RIME_JWT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "rime.fullname" . }}-jwt-secret
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
