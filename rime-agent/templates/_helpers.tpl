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
app.kubernetes.io/owned-by: "ri"
{{- if .Values.rimeAgent.commonAnnotations}}
{{ toYaml .Values.rimeAgent.commonAnnotations }}
{{- end }}
{{- end -}}

{{/*
Monitoring annotations to add to pods.
*/}}
{{- define "rime-agent.monitoringAnnotations"  -}}
{{- if .monitoring.enabled}}
prometheus.io/scrape: "true"
prometheus.io/path: "/metrics"
prometheus.io/port: "{{ .monitoring.port }}"
{{- end }}
{{- if .monitoring.datadogEnabled }}
tags.datadoghq.com/service: {{ .name }}
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
    logging:
        verbose: {{ .Values.rimeAgent.verbose }}
    metrics:
        enabled: {{ .Values.rimeAgent.monitoring.enabled }}
        port: {{ .Values.rimeAgent.monitoring.port }}
    connections:
        addresses: {}
dataplane:
    agentID: {{ .Values.rimeAgent.id }}
    {{- if .Values.rimeAgent.connections.nginxControllerRestAddr }}
    platformAddress: {{ .Values.rimeAgent.connections.nginxControllerRestAddr }}
    {{- else }}
    platformAddress: {{ .Values.rimeAgent.connections.platformAddress }}
    {{- end }}
    connections:
        addresses:
            crossPlaneServerAddr: "{{ include "rime-agent.fullname" . }}-{{ .Values.rimeAgent.rimeCrossPlaneServer.name }}:{{ .Values.rimeAgent.rimeCrossPlaneServer.port }}"
            {{- if .Values.rimeAgent.fileServer.enabled }}
            dataPlaneFileServerAddr: "{{ include "rime-agent.fullname" . }}-{{ .Values.rimeAgent.fileServer.name }}:{{ .Values.rimeAgent.fileServer.port }}"
            {{- end }}
            {{- if .Values.rimeAgent.detectionServer.enabled }}
            generativeTestingDetectionEngineAddr: "{{ include "rime-agent.fullname" . }}-{{ .Values.rimeAgent.detectionServer.name }}:{{ .Values.rimeAgent.detectionServer.port }}"
            {{- end }}
{{- end }}

{{/*
Name of the issuer to be used for cert-manager Certificates for RIME services.
*/}}
{{- define "tls.certificateIssuerName" -}}
{{- default (printf "rime-%s-ca-issuer" .Release.Namespace) .Values.tls.certificateSpec.issuerRef.name }}
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
Return the service account name used by the agent deployment launcher.
*/}}
{{- define "rime-agent.agentDeploymentLauncher.serviceAccountName" -}}
{{- if .Values.rimeAgent.agentDeploymentLauncher.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "rime-agent.fullname" .) .Values.rimeAgent.agentDeploymentLauncher.name) .Values.rimeAgent.agentDeploymentLauncher.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.rimeAgent.agentDeploymentLauncher.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the service account name used by the agent deployment operator.
*/}}
{{- define "rime-agent.agentDeploymentOperator.serviceAccountName" -}}
{{- if .Values.rimeAgent.agentDeploymentOperator.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "rime-agent.fullname" .) .Values.rimeAgent.agentDeploymentOperator.name) .Values.rimeAgent.agentDeploymentOperator.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.rimeAgent.agentDeploymentOperator.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the service account name used by the rimeServer.
*/}}
{{- define "rime-agent.rimeServer.serviceAccountName" -}}
{{- if .Values.rimeAgent.rimeCrossPlaneServer.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "rime-agent.fullname" .) .Values.rimeAgent.rimeCrossPlaneServer.name) .Values.rimeAgent.rimeCrossPlaneServer.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.rimeAgent.rimeCrossPlaneServer.serviceAccount.name }}
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
{{- default (printf "%s-api-secret" (include "rime-agent.fullname" .)) .Values.rimeAgent.existingSecretName }}
{{- end -}}

{{/*
Return the name used for secrets containing costum ca cert used by agent services.
*/}}
{{- define "rime-agent.customCACertSecretName" -}}
{{- default (printf "%s-custom-ca-cert-secret" (include "rime-agent.fullname" .)) .Values.rimeAgent.customCACertSecretName }}
{{- end -}}

{{/*
Return the name of the signing key secret to create JWTs for talking to the CP.
*/}}
{{- define "rime-agent.signingKeySecretName" -}}
{{- default (printf "%s-generated-secrets" (include "rime-agent.fullname" .)) .Values.rimeAgent.existingSigningKeySecretName }}
{{- end -}}

{{/*
Return the name of the created Secret containing docker config.
*/}}
{{- define "rime-agent.dockerSecretName" -}}
{{ include "rime-agent.fullname" . }}-docker-secret
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

{{/*
Return the service account name used by the file server.
*/}}
{{- define "rime-agent.fileServer.serviceAccountName" -}}
{{- if .Values.rimeAgent.fileServer.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "rime-agent.fullname" .) .Values.rimeAgent.fileServer.name) .Values.rimeAgent.operator.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.rimeAgent.fileServer.serviceAccount.name }}
{{- end -}}
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
Name for the ConfigMap containing the model name to address mapping.
Note: this ConfigMap is defined in the `ri-detection-resources` Helm chart, so this makes
an assumption about how that is created.
*/}}
{{- define "rime-agent.modelConnectionConfigMapName" -}}
{{- printf "%s-ri-detection-resources-model-connection-map-conf" .Release.Name }}
{{- end -}}

{{/*
Address of the signal-gen YARA service for the detection engine to connect to it.
Note: this service is defined in the `ri-detection-resources` Helm chart, so this makes
an assumption about how that name is determined as well as the port value.
*/}}
{{- define "rime-agent.signalGenYaraServerAddr" -}}
{{- printf "%s-signalgen-yara:5025" .Release.Name }}
{{- end -}}

{{/*
Name of configmap containing the configuration for the troubleshooting support bundle.
*/}}
{{- define "rime-agent.supportBundleConfigMapName" -}}
{{- printf "%s-support-bundle-conf" .Release.Name }}
{{- end -}}
