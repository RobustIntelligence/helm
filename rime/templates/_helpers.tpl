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
Common annotations added to all resources.
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
    tls:
        caPath: "/var/tmp/tls/common/ca.crt"
        certPath: "/var/tmp/tls/common/tls.crt"
        keyPath: "/var/tmp/tls/common/tls.key"
        {{/*
        Flags to control TLS communication within the control plane
        */}}
        mongoTLSEnabled: {{ .Values.tls.mongoEnabled }}
        restTLSEnabled: {{ .Values.tls.restEnabled }}
        vaultTLSDisabled: {{ .Values.tls.vaultDisabled }}
        grpcTLSEnabled: {{ .Values.tls.grpcEnabled }}
    mongo:
        databaseName: {{ default "rime-store" .Values.external.mongo.databaseName }}
        urlPrefix: {{ default "mongodb+srv://" .Values.external.mongo.urlPrefix }}
        {{- if .Values.external.mongo.url }}
        url: {{ .Values.external.mongo.url }}
        {{- else }}
        url: {{ include "rime.fullname" . }}-mongodb-headless
        {{- end }}
        replicaSetName: "{{ .Values.mongodb.replicaSetName }}"
        maxNumberConnections: {{ default 100 .Values.external.mongo.maxNumberConnections }}
        isExternal: {{ .Values.external.mongo.enabled }}
        {{/*
        External Mongo Configuration. Note that if external Mongo is enabled,
        TLS is required.  To provide TLS files to communicate with the
        external mongo, create a config map in cluster with the cert files
        and pass the name of the config map to .Values.external.mongo.configMapName
        The cert files will be mounted to the paths specified below and then
        read by each server.
        */}}
        externalMongoCaPath: "/var/tmp/tls/external/mongo/ca.crt"
        externalMongoCertPath: "/var/tmp/tls/external/mongo/tls.crt"
        externalMongoKeyPath: "/var/tmp/tls/external/mongo/tls.key"
    vault:
        isExternal: {{ .Values.external.vault.enabled }}
        {{- if .Values.external.vault.url }}
        url: {{ .Values.external.vault.url }}
        {{- else }}
        url: "{{ include "rime.fullname" . }}-vault-0.{{ include "rime.fullname" . }}-vault-internal:8200"
        {{- end }}
        mountPath: "secret/"
        {{- if .Values.external.vault.roleName }}
        roleName: {{ .Values.external.vault.roleName }}
        {{- end }}
        {{- if .Values.external.vault.namespace }}
        namespace: {{ .Values.external.vault.namespace }}
        {{- end }}
        tokenPath: "/var/run/secrets/kubernetes.io/serviceaccount/token"
        {{- if .Values.external.vault.kvVersion }}
        kvVersion: {{ .Values.external.vault.kvVersion }}
        {{- end }}
        {{/*
        External Vault Configuration. Note that if external Vault is enabled,
        TLS is required.  To provide TLS files to communicate with the
        external vault, create a secret in cluster with the cert files
        and pass the name of the secret to .Values.external.vault.secretName
        The cert files will be mounted to the paths specified below and then
        read by each server.
        */}}
        externalVaultCaPath: "/var/tmp/tls/external/vault/ca.crt"
        externalVaultCertPath: "/var/tmp/tls/external/vault/tls.crt"
        externalVaultKeyPath: "/var/tmp/tls/external/vault/tls.key"
    metrics:
        enabled: "{{ .Values.rime.monitoring.enabled }}"
        port: "{{ .Values.rime.monitoring.port }}"
    configuration:
        verbose: "{{ .Values.rime.verbose }}"
    connections:
        addresses:
            agentManagerServerAddr: "{{ include "rime.fullname" . }}-{{ .Values.rime.agentManagerServer.name }}:{{ .Values.rime.agentManagerServer.port }}"
            authServerAddr: "{{ include "rime.fullname" . }}-{{ .Values.rime.authServer.name }}:{{ .Values.rime.authServer.grpcPort }}"
            featureFlagServerAddr: "{{ include "rime.fullname" . }}-{{ .Values.rime.featureFlagServer.name }}:{{ .Values.rime.featureFlagServer.port }}"
            firewallServerAddr: "{{ include "rime.fullname" . }}-{{ .Values.rime.firewallServer.name }}:{{ .Values.rime.firewallServer.port }}"
            grpcWebServerAddr: "{{ include "rime.fullname" . }}-{{ .Values.rime.webServer.name }}:{{ .Values.rime.webServer.grpcPort }}"
            uploadServerAddr: "{{ include "rime.fullname" . }}-{{ .Values.rime.uploadServer.name }}:{{ .Values.rime.uploadServer.port }}"
            {{- if .Values.rime.imageRegistryServer.enabled }}
            imageRegistryServerAddr: "{{ include "rime.fullname" . }}-{{ .Values.rime.imageRegistryServer.name }}:{{ .Values.rime.imageRegistryServer.port }}"
            {{- end }}
            modelTestingServerAddr: "{{ include "rime.fullname" . }}-{{ .Values.rime.modelTestingServer.name }}:{{ .Values.rime.modelTestingServer.port }}"
    crossServiceKeyRef:
        secretName: {{ include "rime.generatedSecretsName" . }}
        key: crossServiceKey
{{- end }}

{{/*
Return the service account name used by the services that need blob storage.
The service account has read and write access to the S3 bucket used for the blob storage.
If we are creating a service account, use the service name by default. Otherwise allow
the user to specify the service account name.
*/}}
{{- define "rime.datasetManagerServer.serviceAccountName" -}}
{{- if .Values.rime.datasetManagerServer.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "rime.fullname" .) .Values.rime.datasetManagerServer.name) .Values.rime.datasetManagerServer.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.rime.datasetManagerServer.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the service account name used by the image registry server to access the
image registry used to store docker images.
*/}}
{{- define "rime.imageRegistryServer.serviceAccountName" -}}
{{- if .Values.rime.imageRegistryServer.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "rime.fullname" .) .Values.rime.imageRegistryServer.name) .Values.rime.imageRegistryServer.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.rime.imageRegistryServer.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the service account name used by image registry jobs to access the
image registry used to store docker images.
*/}}
{{- define "rime.imageRegistryServer.imageRegistryJob.serviceAccountName" -}}
{{- if .Values.rime.imageRegistryServer.imageRegistryJob.serviceAccount.create -}}
    {{ default (printf "%s-%s-job" (include "rime.fullname" .) .Values.rime.imageRegistryServer.name) .Values.rime.imageRegistryServer.imageRegistryJob.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.rime.imageRegistryServer.imageRegistryJob.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the service account name used by the upload server to read secrets
for unsealing vault.
*/}}
{{- define "rime.uploadServer.serviceAccountName" -}}
{{- if .Values.rime.uploadServer.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "rime.fullname" .) .Values.rime.uploadServer.name) .Values.rime.uploadServer.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.rime.uploadServer.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
Return the service account name used by the vault job to write secrets
for unsealing vault.
*/}}
{{- define "rime.initVault.serviceAccountName" -}}
{{- if .Values.rime.initVault.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "rime.fullname" .) .Values.rime.initVault.name) .Values.rime.initVault.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.rime.initVault.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the service account name used by the init mongo tls job to read secrets
for mongo tls.
*/}}
{{- define "rime.initMongoTLS.serviceAccountName" -}}
{{- if .Values.rime.initMongoTLS.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "rime.fullname" .) .Values.rime.initMongoTLS.name) .Values.rime.initMongoTLS.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.rime.initMongoTLS.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the service account name used by the rollout restart job to operate deployments and statefulsets.
*/}}
{{- define "rime.rolloutRestart.serviceAccountName" -}}
{{- if .Values.rime.rolloutRestart.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "rime.fullname" .) .Values.rime.rolloutRestart.name) .Values.rime.rolloutRestart.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.rime.rolloutRestart.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the service account name used by the model testing server to access configmaps.
*/}}
{{- define "rime.modelTestingServer.serviceAccountName" -}}
{{- if .Values.rime.modelTestingServer.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "rime.fullname" .) .Values.rime.modelTestingServer.name) .Values.rime.modelTestingServer.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.rime.modelTestingServer.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the service account name used by the web server to read secrets.
If we are creating a service account, use the service name by default. Otherwise allow
the user to specify the service account name.
*/}}
{{- define "rime.webServer.serviceAccountName" -}}
{{- if .Values.rime.webServer.serviceAccount.create -}}
    {{ default (printf "%s-%s" (include "rime.fullname" .) .Values.rime.webServer.name) .Values.rime.webServer.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.rime.webServer.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the name of user provided secrets used by all RIME services. If the user
provides a name, we expect the secret to already exist.
*/}}
{{- define "rime.commonSecretName" -}}
{{- default (printf "%s-secrets" (include "rime.fullname" .)) .Values.rime.secrets.existingSecretName }}
{{- end }}

{{/*
Return the name of the secret containing generated secrets used by RIME services
*/}}
{{- define "rime.generatedSecretsName" -}}
{{- printf "%s-generated-secrets" (include "rime.fullname" .) }}
{{- end }}

{{/*
Common environment variables used in all RIME services.
*/}}
{{- define "rime.commonEnv" -}}
- name: RIME_JWT
  valueFrom:
    secretKeyRef:
      name: {{ include "rime.commonSecretName" . }}
      key: rimeLicense
- name: RIME_CROSS_SERVICE_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "rime.generatedSecretsName" . }}
      key: crossServiceKey
{{- end }}

{{/*
Web app host environmental variable used in our application code.
*/}}
{{- define "rime.webAppHostEnv" -}}
{{- if .Values.rime.webAppHostOverride }}
- name: RIME_WEB_APP_HOST
  value: {{ .Values.rime.webAppHostOverride }}
{{- else }}
- name: RIME_WEB_APP_HOST
  value: "rime.{{ .Values.rime.domain }}"
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for Horizontal Pod Autoscaler.
*/}}
{{- define "rime.hpa.apiVersion" -}}
{{- if $.Capabilities.APIVersions.Has "autoscaling/v2/HorizontalPodAutoscaler" }}
{{- print "autoscaling/v2" }}
{{- else }}
{{- print "autoscaling/v2beta2" }}
{{- end }}
{{- end }}

{{/*
Volume Mounts for External TLS Secrets
*/}}
{{- define "rime.externalTLSSecretVolumeMounts" -}}
{{- if .Values.external.mongo.secretName }}
- name: "external-mongo-tls"
  mountPath: /var/tmp/tls/external/mongo
  readOnly: true
{{- end}}
{{- if .Values.external.vault.secretName }}
- name: "external-vault-tls"
  mountPath: /var/tmp/tls/external/vault
  readOnly: true
{{- end }}
{{- end }}

{{/*
Volumes for External TLS Secrets
*/}}
{{- define "rime.externalTLSSecretVolumes" -}}
{{- if .Values.external.mongo.secretName }}
- name: "external-mongo-tls"
  secret:
    secretName: {{ .Values.external.mongo.secretName }}
{{- end }}
{{- if .Values.external.vault.secretName }}
- name: "external-vault-tls"
  secret:
   secretName: {{ .Values.external.vault.secretName }}
{{- end }}
{{- end }}
