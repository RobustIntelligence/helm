{{/*
Expand the name of the chart.
*/}}
{{- define "rime-agent.name" -}}
{{- default .Chart.Name .Values.rimeAgent.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to
this (by the DNS naming spec). If release name contains chart name it will
be used as a full name.
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
Selector labels
*/}}
{{- define "rime-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rime-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
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
{{- if .Values.rimeAgent.commonLabels}}
{{ toYaml .Values.rimeAgent.commonLabels }}
{{- end }}
{{- end -}}

{{/*
Common annotations added to all resources.
*/}}
{{- define "rime-agent.annotations" -}}
helm.sh/chart: {{ include "rime-agent.chart" . }}
{{ include "rime-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/part-of: {{ template "rime-agent.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.rimeAgent.commonAnnotations}}
{{ toYaml .Values.rimeAgent.commonAnnotations }}
{{- end }}
{{- end -}}

{{/*
Common flags passed to all the Agent servers. Be careful when modifying these values!
*/}}
{{- define "rime-agent.serverArgs" -}}
common:
    {{- if .Values.tls.crossplaneEnabled }}
    tls:
        caPath: "/var/tmp/tls/common/ca.crt"
        certPath: "/var/tmp/tls/common/tls.crt"
        keyPath: "/var/tmp/tls/common/tls.key"
        grpcTLSEnabled: true
    {{- end }}
    connections:
        addresses:
            {{- if .Values.rimeAgent.connections.agentManagerAddress}}
            agentManagerServerAddr: {{ .Values.rimeAgent.connections.agentManagerAddress }}
            {{- end }}
            {{- if .Values.rimeAgent.connections.uploadServerAddress}}
            uploadServerAddr: {{ .Values.rimeAgent.connections.uploadServerAddress }}
            {{- end }}
dataplane:
    isInternal: {{ .Values.rimeAgent.isInternal }}
    platformAddress: {{ .Values.rimeAgent.connections.platformAddress }}
{{- end }}

{{/*
Return the service account name used by the operator controller manager.
*/}}
{{- define "rime-agent.launcher.serviceAccountName" -}}
{{- if .Values.rimeAgent.launcher.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "rime-agent.fullname" .) .Values.rimeAgent.launcher.name) .Values.rimeAgent.launcher.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.rimeAgent.launcher.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the service account name used by the model testing jobs, which has
access to read S3 buckets.
*/}}
{{- define "rime-agent.modelTestJob.serviceAccountName" -}}
{{- if .Values.rimeAgent.operator.modelTestJob.serviceAccount.create -}}
    {{ default "rime-agent-model-tester" .Values.rimeAgent.operator.modelTestJob.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.rimeAgent.operator.modelTestJob.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the name used for secrets containing credentials used by agent services.
*/}}
{{- define "rime-agent.secretName" -}}
{{ include "rime-agent.fullname" . }}-secret
{{- end -}}

{{/*
Return the name of the created Secret containing docker config.
*/}}
{{- define "rime-agent.dockerSecretName" -}}
{{ include "rime-agent.fullname" . }}-docker
{{- end -}}

{{/*
Return image pull secrets to be used for all images (agent and model testing
images).
*/}}
{{- define "rime-agent.imagePullSecretsYaml" -}}
{{- if (gt (len .Values.rimeAgent.images.imagePullSecrets) 0) -}}
imagePullSecrets:
{{ .Values.rimeAgent.images.imagePullSecrets | toYaml | indent 2 }}
{{- else if .Values.rimeAgent.dockerCredentialsPayload -}}
imagePullSecrets:
    - name : {{ include "rime-agent.dockerSecretName" . }}
{{- else }}
imagePullSecrets: []
{{- end -}}
{{- end -}}

{{/*
Return the service account name used by the operator controller manager.
*/}}
{{- define "rime-agent.operator.serviceAccountName" -}}
{{- if .Values.rimeAgent.operator.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "rime-agent.fullname" .) .Values.rimeAgent.operator.name) .Values.rimeAgent.operator.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.rimeAgent.operator.serviceAccount.name }}
{{- end -}}
{{- end -}}
