{{/*
Unique additions to the imageRegistryServer's server.config ConfigMap.
*/}}
{{- define "rime.imageRegistryServer.serverArgs" -}}
{{- toYaml .Values.rime.imageRegistryServer.config }}
{{- end -}}
{{/*
Unique additions to the imageRegistryServer's image_builder_job_configmap.config ConfigMap.
*/}}
{{- define "rime.imageRegistryServer.imageBuilderJobConfigMap" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: job-conf-placeholder
immutable: true
{{- end -}}
{{/*
Unique additions to the imageRegistryServer's image_builder_job.config ConfigMap.
*/}}
{{- define "rime.imageRegistryServer.imageBuilderJob" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: job-placeholder
spec:
  # Terminate job after at most 1 hours; see
  # https://kubernetes.io/docs/concepts/workloads/controllers/job/#job-termination-and-cleanup
  activeDeadlineSeconds: 3600
  # TTL job 48 hours after finished; see
  # https://kubernetes.io/docs/concepts/workloads/controllers/job/#ttl-mechanism-for-finished-jobs
  ttlSecondsAfterFinished: 172800
  template:
    metadata:
      labels:
        {{- include "rime.labels" . | nindent 8 }}
        {{- with .Values.rime.imageRegistryServer.imageRegistryJob.labels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      annotations:
        {{- include "rime.annotations" . | nindent 8 }}
        {{- with .Values.rime.imageRegistryServer.imageRegistryJob.annotations }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- include "rime.monitoringAnnotations" (dict "monitoring" .Values.rime.monitoring "name" .Values.rime.imageRegistryServer.imageRegistryJob.name ) | nindent 8 }}
    spec:
      {{- with .Values.rime.images.imagePullSecrets }}
      imagePullSecrets:
          {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.rime.imageRegistryServer.imageRegistryJob.securityContext }}
      securityContext:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      # TODO(Figure out service account naming scheme)
      serviceAccountName: {{ include "rime.imageRegistryServer.imageRegistryJob.serviceAccountName" . }}
      initContainers:
      # This init container is designed to wait until the source image
      # required by the main container can be pulled thereby ensuring
      # a strict temporal ordering of dependent builder jobs.
      - name: {{ .Chart.Name }}-src-waiter
        # The source image name must be filled in by the job creator.
        image: ""
        imagePullPolicy: {{ .Values.rime.images.imageBuilderImage.pullPolicy }}
        command: ['sh', '-c', 'true']
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.rime.images.imageBuilderImage.registry }}/{{ .Values.rime.images.imageBuilderImage.name }}"
        imagePullPolicy: {{ .Values.rime.images.imageBuilderImage.pullPolicy }}
        {{- if .Values.rime.imageRegistryServer.imageRegistryJob.privilegedOverride }}
        securityContext:
          privileged: true
        {{- end}}
        {{- with .Values.rime.imageRegistryServer.imageRegistryJob.extraEnv }}
        env:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- with .Values.rime.imageRegistryServer.imageRegistryJob.resources }}
        resources:
            {{- toYaml . | nindent 10 }}
        {{- end }}
        # This command depends on setting environmental variables:
        #  * SOURCE - source repo uri (without the version tag).
        #  * SOURCE_AUTH_MODE - auth mode for using the source image.
        #  * IMAGE_NAME - the name used by RIME to identify the new image.
        #  * DESTINATION - destination repo uri (without the version tag).
        #  * DESTINATION_AUTH_MODE - auth mode for writing the destination image.
        #  * VERSION - version for the source and destination image.
        #  * AUTH_TOKEN - the auth token for internal APIs.
        # to configure the target image being built.
        command:
          - "/builder/build_image.sh"
        args:
          - "--source=$(SOURCE):$(VERSION)"
          - "--source_auth_mode=$(SOURCE_AUTH_MODE)"
          # Currently only docker auth files can be added and we add this
          # flag whether or not it is required for the source image.
          {{- if .Values.rime.imageRegistryServer.imageRegistryJob.dockerSecretName }}
          - "--source_auth_file=/auth/.docker/config.json"
          {{- end }}
          - "--workingdir=/build-config/"
          - "--destination=$(DESTINATION):$(VERSION)"
          - "--destination_auth_mode=$(DESTINATION_AUTH_MODE)"
          # Currently only docker auth files can be added and we add this
          # flag whether or not it is required for the destination image.
          {{- if .Values.rime.imageRegistryServer.imageRegistryJob.dockerSecretName }}
          - "--destination_auth_file=/auth/.docker/config.json"
          {{- end }}
          - "--image_name=$(IMAGE_NAME)"
          - "--ca_path=/var/tmp/{{ .Values.rime.imageRegistryServer.imageRegistryJob.name }}-tls/ca.crt"
          - "--cert_path=/var/tmp/{{ .Values.rime.imageRegistryServer.imageRegistryJob.name }}-tls/tls.crt"
          - "--key_path=/var/tmp/{{ .Values.rime.imageRegistryServer.imageRegistryJob.name }}-tls/tls.key"
          - "--image_registry_addr={{ include "rime.fullname" . }}-{{ .Values.rime.imageRegistryServer.name }}:{{ .Values.rime.imageRegistryServer.restPort }}"
          - "--enable_cert_manager={{ .Values.tls.enableCertManager }}"
          - "--auth_token=$(AUTH_TOKEN)"
        volumeMounts:
          # This mounts the docker credentials used for pulling the base image from Docker.
          # This is only mounted if a dockerSecretName is provided to the image registry module.
          {{- if .Values.rime.imageRegistryServer.imageRegistryJob.dockerSecretName }}
          - name: docker-config
            mountPath: "/auth/.docker"
          {{- end }}
          {{- if .Values.tls.enableCertManager }}
          - name: {{ .Values.rime.imageRegistryServer.imageRegistryJob.name }}-{{ .Release.Namespace }}-tls
            mountPath: /var/tmp/{{ .Values.rime.imageRegistryServer.imageRegistryJob.name }}-tls
            readOnly: true
          {{- end }}
          {{- with .Values.rime.imageRegistryServer.imageRegistryJob.extraVolumeMounts }}
            {{- toYaml . | nindent 10 }}
          {{- end }}
      restartPolicy: Never
      volumes:
        # This provides the volume containing the Docker secrets but is only
        # constructed if a dockerSecretName is provided to the image registry module.
        {{- if .Values.rime.imageRegistryServer.imageRegistryJob.dockerSecretName }}
        - name: docker-config
          projected:
            sources:
            - secret:
                name: {{ .Values.rime.imageRegistryServer.imageRegistryJob.dockerSecretName }}
                items:
                  - key: .dockerconfigjson
                    path: config.json
        {{- end }}
        {{- if .Values.tls.enableCertManager }}
        - name: {{ .Values.rime.imageRegistryServer.imageRegistryJob.name }}-{{ .Release.Namespace }}-tls
          secret:
            secretName: {{ .Values.rime.imageRegistryServer.imageRegistryJob.name }}-{{ .Release.Namespace }}-tls
        {{- end }}
        {{- with .Values.rime.imageRegistryServer.imageRegistryJob.extraVolumes }}
          {{- toYaml . | nindent 8 }}
        {{- end }}
        # Mount an additional volume containing the Dockerfile.
      {{- with .Values.rime.imageRegistryServer.imageRegistryJob.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.rime.imageRegistryServer.imageRegistryJob.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.rime.imageRegistryServer.imageRegistryJob.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
  backoffLimit: {{ .Values.rime.imageRegistryServer.imageRegistryJob.backoffLimit }}
{{- end -}}
