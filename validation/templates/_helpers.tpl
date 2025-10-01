{{/*
Expand the name of the chart.
*/}}
{{- define "ai-validation.name" -}}
{{- default .Chart.Name .Values.aiValidation.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to
this (by the DNS naming spec). If release name contains chart name it will
be used as a full name.
*/}}
{{- define "ai-validation.fullname" -}}
{{- if .Values.aiValidation.fullNameOverride }}
{{- .Values.aiValidation.fullNameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.aiValidation.nameOverride }}
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
{{- define "ai-validation.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ai-validation.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ai-validation.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ai-validation.labels" -}}
helm.sh/chart: {{ include "ai-validation.chart" . }}
{{ include "ai-validation.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.aiValidation.commonLabels}}
{{ toYaml .Values.aiValidation.commonLabels }}
{{- end }}
{{- end -}}

{{/*
Common annotations added to all resources.
*/}}
{{- define "ai-validation.annotations" -}}
helm.sh/chart: {{ include "ai-validation.chart" . }}
{{ include "ai-validation.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/part-of: {{ template "ai-validation.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/owned-by: "ri"
{{- if .Values.aiValidation.commonAnnotations}}
{{ toYaml .Values.aiValidation.commonAnnotations }}
{{- end }}
{{- end -}}

{{/*
Monitoring annotations to add to pods.
*/}}
{{- define "ai-validation.monitoringAnnotations"  -}}
{{- if .monitoring.enabled}}
prometheus.io/scrape: "true"
prometheus.io/path: "/metrics"
prometheus.io/port: "{{ .monitoring.port }}"
{{- end }}
{{- end -}}

{{- define "ai-validation.serverArgs" -}}
common:
    logging:
        verbose: {{ .Values.aiValidation.verbose }}
    metrics:
        enabled: {{ .Values.aiValidation.monitoring.enabled }}
        port: {{ .Values.aiValidation.monitoring.port }}
    connections:
        {{- if .Values.aiValidation.detectionServer.enabled }}
        addresses:
            generativeTestingDetectionEngineAddr: "{{ .Values.aiValidation.detectionServer.name }}:{{ .Values.aiValidation.detectionServer.port }}"
        {{- end }}
{{- end }}

{{/*
Return the service account name used by the Generative Validation Service.
*/}}
{{- define "ai-validation.generativeValidationService.serviceAccountName" -}}
{{- if .Values.aiValidation.generativeValidationService.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "ai-validation.fullname" .) .Values.aiValidation.generativeValidationService.name) .Values.aiValidation.generativeValidationService.serviceAccount.name | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.aiValidation.generativeValidationService.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the name used for secrets containing credentials used by AI Validation services.
*/}}
{{- define "ai-validation.secretName" -}}
{{- default (printf "%s-api-secret" (include "ai-validation.fullname" .)) .Values.aiValidation.existingSecretName }}
{{- end -}}

{{/*
Return the name of the created Secret containing docker config.
*/}}
{{- define "ai-validation.dockerSecretName" -}}
{{ include "ai-validation.fullname" . }}-docker-secret
{{- end -}}

{{/*
Return image pull secrets to be used for all images.
*/}}
{{- define "ai-validation.imagePullSecretsYaml" -}}
{{- if (gt (len .Values.aiValidation.images.imagePullSecrets) 0) -}}
imagePullSecrets:
{{ .Values.aiValidation.images.imagePullSecrets | toYaml | indent 2 }}
{{- else if .Values.aiValidation.dockerCredentialsPayload -}}
imagePullSecrets:
    - name : {{ include "ai-validation.dockerSecretName" . }}
{{- else }}
imagePullSecrets: []
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for Horizontal Pod Autoscaler.
*/}}
{{- define "ai-validation.hpa.apiVersion" -}}
{{- if $.Capabilities.APIVersions.Has "autoscaling/v2/HorizontalPodAutoscaler" }}
{{- print "autoscaling/v2" }}
{{- else }}
{{- print "autoscaling/v2beta2" }}
{{- end }}
{{- end }}

{{/*
Name for the ConfigMap containing the model name to address mapping.
Note: this ConfigMap is defined in the `ri-detection-resources` Helm chart, so this makes
an assumption about how that is created.
*/}}
{{- define "ai-validation.modelConnectionConfigMapName" -}}
{{- printf "%s-ri-detection-resources-model-connection-map-conf" .Release.Name }}
{{- end -}}

{{/*
Return the appropriate apiVersion for Horizontal Pod Autoscaler.
*/}}
{{- define "rime-agent.hpa.apiVersion" -}}
{{- if $.Capabilities.APIVersions.Has "autoscaling/v2/HorizontalPodAutoscaler" }}
{{- print "autoscaling/v2" }}
{{- else }}
{{- print "autoscaling/v2beta2" }}
{{- end }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "ai-defense-onpremises.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ai-defense-onpremises.fullname" -}}
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
Common labels
*/}}
{{- define "ai-defense-onpremises.labels" -}}
{{- if .Chart.AppVersion -}}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "ai-defense-onpremises.name" . }}
{{- end }}
