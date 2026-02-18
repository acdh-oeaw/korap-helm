{{- define "korap.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "korap.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "korap.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end }}

{{- define "korap.labels" -}}
app.kubernetes.io/name: {{ include "korap.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end }}

{{- define "korap.superClientInfo" -}}
{{- $config := ((.Values.full | default dict).superClientInfo | default dict) -}}
{{- $clientSecret := $config.clientSecret | default "auto-generate" -}}
{{- if eq $clientSecret "auto-generate" -}}
{{- $clientSecret = randAlphaNum 32 -}}
{{- end -}}
{
  "client_id": "{{ $config.clientId | default "korap-client" }}",
  "client_secret": "{{ $clientSecret }}",
  "client_name": "{{ $config.clientName | default "KorAP" }}",
  "client_type": "{{ $config.clientType | default "CONFIDENTIAL" }}",
  "client_description": "{{ $config.clientDescription | default "KorAP Kalamar Frontend" }}",
  "client_url": "{{ $config.clientUrl | default "http://localhost:64543" }}",
  "client_redirect_uri": "{{ $config.clientRedirectUri | default "http://localhost:64543/oauth2/callback" }}",
  "super": {{ $config.super | default true }},
  "refresh_token_expiry": {{ $config.refreshTokenExpiry | default 31536000 }},
  "permitted": {{ $config.permitted | default true }}
}
{{- end }}
