{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "rasa-x.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rasa-x.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "rasa-x.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels.
*/}}
{{- define "rasa-x.labels" -}}
helm.sh/chart: {{ include "rasa-x.chart" . }}
{{ include "rasa-x.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels.
*/}}
{{- define "rasa-x.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rasa-x.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Common container spec.
*/}}
{{- define "rasa-x.spec" -}}
{{- include "rasa-x.imagePullSecrets" . | nindent 6 }}
{{- include "rasa-x.securityContext" . | nindent 6 }}
{{- end -}}

{{/*
Secrets to pull images from private registries.
*/}}
{{- define "rasa-x.imagePullSecrets" -}}
 {{- with .Values.images.imagePullSecrets -}}
imagePullSecrets:
{{ toYaml . }}
 {{- end -}}
{{- end -}}

{{/*
Security context for the containers.
*/}}
{{- define "rasa-x.securityContext" -}}
 {{- with .Values.securityContext -}}
securityContext:
  {{- toYaml . | nindent 2 }}
 {{- end -}}
{{- end -}}

{{/*
Returns the name of the rasa secret.
*/}}
{{- define "rasa-x.secret" -}}
  {{- if .Values.rasaSecret -}}
{{ .Values.rasaSecret }}
  {{- else -}}
{{ .Release.Name }}-rasa
  {{- end -}}
{{- end -}}

{{/*
Return the name of the config map which stores the rasa configuration files.
*/}}
{{- define "rasa-x.rasa.configuration-files" -}}
"{{ .Release.Name }}-rasa-configuration-files"
{{- end -}}

{{/*
Return the rasa-x host.
*/}}
{{- define "rasa-x.host" -}}
  {{- include "rasa-x.fullname" . -}}-rasa-x
{{- end -}}

{{/*
Return the duckling host.
*/}}
{{- define "duckling.host" -}}
  {{- include "rasa-x.fullname" . -}}-duckling
{{- end -}}

{{/*
Return the name of the config map which stores the rasa x configuration files.
*/}}
{{- define "rasa-x.rasa-x.configuration-files" -}}
"{{ .Release.Name }}-rasa-x-configuration-files"
{{- end -}}

{{/*
Return the name of the rasa x volume claim.
*/}}
{{- define "rasa-x.rasa-x.claim" -}}
{{ .Values.rasax.persistence.existingClaim | default (printf "%s-%s" .Release.Name "rasa-x-claim") }}
{{- end -}}

{{/*
Return the name of config map which stores the nginx agreement.
*/}}
{{- define "rasa-x.nginx.agreement" -}}
"{{ .Release.Name }}-agreement"
{{- end -}}

{{/*
Return the port of the action container.
*/}}
{{- define "rasa-x.custom-actions.port" -}}
{{- default 5055 .Values.app.port -}}
{{- end -}}

{{/*
Include rasa extra env vars.
*/}}
{{- define "rasa.extra.envs" -}}
  {{- if .Values.rasa.extraEnvs -}}
{{ toYaml .Values.rasa.extraEnvs }}
  {{- end -}}
{{- end -}}

{{/*
Include rasax extra env vars.
*/}}
{{- define "rasax.extra.envs" -}}
  {{- if .Values.rasax.extraEnvs -}}
{{ toYaml .Values.rasax.extraEnvs }}
  {{- end -}}
{{- end -}}

{{/*
Include extra env vars for the EventService.
*/}}
{{- define "rasax.event-service.extra.envs" -}}
  {{- if .Values.eventService.extraEnvs -}}
{{ toYaml .Values.eventService.extraEnvs }}
  {{- end -}}
{{- end -}}

{{/*
Include extra env vars for the database migration service.
*/}}
{{- define "rasax.db-migration-service.extra.envs" -}}
  {{- if .Values.dbMigrationService.extraEnvs -}}
{{ toYaml .Values.dbMigrationService.extraEnvs }}
  {{- end -}}
{{- end -}}

{{/*
Return the storage class name which should be used.
*/}}
{{- define "rasa-x.persistence.storageClass" -}}
{{- if .Values.global.storageClass }}
  {{- if (eq "-" .Values.global.storageClass) }}
  storageClassName: ""
  {{- else }}
  storageClassName: "{{ .Values.global.storageClass }}"
  {{- end -}}
{{- end -}}
{{- end }}

{{/*
Return the checksum of Rasa values.
*/}}
{{- define "rasa.checksum" -}}
{{ toYaml .Values.rasa | sha256sum }}
{{- end -}}

{{/*
Return the checksum of Rasa X values.
*/}}
{{- define "rasa-x.checksum" -}}
{{ toYaml .Values.rasax | sha256sum }}
{{- end -}}

{{/*
Return the AppVersion value as a default if the rasax.tag variable is not defined.
*/}}
{{- define "rasa-x.version" -}}
{{ .Values.rasax.tag | default .Chart.AppVersion }}
{{- end -}}

{{/*
Return the AppVersion value as a default if the app.tag variable is not defined.
*/}}
{{- define "app.version" -}}
{{ .Values.app.tag | default .Chart.AppVersion }}
{{- end -}}

{{/*
Return the rasa-x.version value as a default if the dbMigrationService.tag variable is not defined.
*/}}
{{- define "db-migration-service.version" -}}
{{ .Values.dbMigrationService.tag | default (include "rasa-x.version" .) }}
{{- end -}}

{{/*
Return 'true' if required version to run the database migration service is correct.
*/}}
{{- define "db-migration-service.requiredVersion" -}}
{{- if semverCompare ">= 0.33.0" (include "db-migration-service.version" .) -}}
{{- print "true" -}}
{{- else -}}
{{- print "false" -}}
{{- end -}}
{{- end -}}

{{/*
Return an init container for database migration.
*/}}
{{- define "initContainer.dbMigration" -}}
{{ if and (eq "true" (include "db-migration-service.requiredVersion" .)) .Values.separateDBMigrationService }}
initContainers:
- name: init-db
  image: {{ .Values.dbMigrationService.initContainer.image }}
  command:
  - 'sh'
  - '-c'
  - "apk update --no-cache && \
    apk add jq curl && \
    until nslookup {{ .Release.Name }}-db-migration-service-headless 1> /dev/null; do echo Waiting for the database migration service; sleep 2; done && \
    until [[ \"$(curl -s http://{{ .Release.Name }}-db-migration-service-headless:{{ .Values.dbMigrationService.port }} | jq -r .status)\" == \"completed\" ]]; do \
    STATUS_JSON=$(curl -s http://{{ .Release.Name }}-db-migration-service-headless:{{ .Values.dbMigrationService.port }}); \
    PROGRESS_IN_PERCENT=$(echo $STATUS_JSON | jq -r .progress_in_percent); \
    STATUS=$(echo $STATUS_JSON | jq -r .status); \
    echo The database migration status: ${STATUS}...${PROGRESS_IN_PERCENT}%; \
    sleep 5; \
    done; \
    echo The database migration status: completed...100%"
{{- end -}}
{{- end -}}
