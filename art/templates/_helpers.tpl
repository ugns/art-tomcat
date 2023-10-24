{{/*
Expand the name of the chart.
*/}}
{{- define "art.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "art.fullname" -}}
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
{{- define "art.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "art.labels" -}}
helm.sh/chart: {{ include "art.chart" . }}
{{ include "art.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "art.selectorLabels" -}}
app.kubernetes.io/name: {{ include "art.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "art.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "art.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Set up configmaps to be mounted to the container
*/}}
{{- define "art.volumes" -}}
        - name: config
          configMap:
            name: {{ template "art.fullname" . }}-config
  {{- if eq (.Values.workStorage.enabled | toString) "true" }}
        - name: work
          persistentVolumeClaim:
            claimName: {{ include "art.fullname" . }}-work
  {{- end }}
  {{- if eq (.Values.exportStorage.enabled | toString) "true" }}
        - name: export
          persistentVolumeClaim:
            claimName: {{ include "art.fullname" . }}-export
  {{- end }}
{{- end -}}

{{/*
Set up volumes to be mounted to the container
*/}}
{{- define "art.mounts" -}}
            - name: config
              mountPath: /config
              readOnly: true
  {{- if eq (.Values.workStorage.enabled | toString) "true" }}
            - name: work
              mountPath: {{ .Values.artCustomSettings.workDirectory | default "/work" }}
  {{- end }}
  {{- if eq (.Values.exportStorage.enabled | toString) "true" }}
            - name: export
              mountPath: {{ .Values.artCustomSettings.exportDirectory | default "/export" }}
  {{- end }}
{{- end -}}

{{/*
Set up volumes to be mounted to the container
*/}}
{{- define "art.volumeclaims" -}}
  volumeClaimTemplates:
    - metadata:
        name: work
         {{- include "art.workVolumeClaim.annotations" . | nindent 6 }}
      spec:
        accessModes:
          - {{ .Values.workStorage.accessMode | default "ReadWriteOnce" }}
        resources:
          requests:
            storage: {{ .Values.workStorage.size }}
           {{- if .Values.workStorage.storageClass }}
        storageClassName: {{ .Values.workStorage.storageClass }}
           {{- end }}
    - metadata:
        name: export
         {{- include "art.exportVolumeClaim.annotations" . | nindent 6 }}
      spec:
        accessModes:
          - {{ .Values.exportStorage.accessMode | default "ReadWriteOnce" }}
        resources:
          requests:
            storage: {{ .Values.exportStorage.size }}
           {{- if .Values.exportStorage.storageClass }}
        storageClassName: {{ .Values.exportStorage.storageClass }}
           {{- end }}
{{- end -}}

{{/*
Sets volumeClaim annotations for work volume
*/}}
{{- define "art.workVolumeClaim.annotations" -}}
  {{- if and (.Values.workStorage.enabled) (.Values.workStorage.annotations) }}
  annotations:
    {{- $tp := typeOf .Values.workStorage.annotations }}
    {{- if eq $tp "string" }}
      {{- tpl .Values.workStorage.annotations . | nindent 4 }}
    {{- else }}
      {{- toYaml .Values.workStorage.annotations | nindent 4 }}
    {{- end }}
  {{- end }}
{{- end }}

{{/*
Sets volumeClaim annotations for export volume
*/}}
{{- define "art.exportVolumeClaim.annotations" -}}
  {{- if and (.Values.exportStorage.enabled) (.Values.exportStorage.annotations) }}
  annotations:
    {{- $tp := typeOf .Values.exportStorage.annotations }}
    {{- if eq $tp "string" }}
      {{- tpl .Values.exportStorage.annotations . | nindent 4 }}
    {{- else }}
      {{- toYaml .Values.exportStorage.annotations | nindent 4 }}
    {{- end }}
  {{- end }}
{{- end }}
