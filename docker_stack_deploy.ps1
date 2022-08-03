 # # Usage
# Set-Variable -Name DOCKER_REPO -Value "<value>"
# Set-Variable -Name DOCKER_TAG -Value "<value>"
# Set-Variable -Name SERVICE_NAME -Value "<value>"
# Set-Variable -Name SECRET_NAME -Value "<value>"
# Set-Variable -Name SPLUNK_URL -Value "<value>"
# Set-Variable -Name SPLUNK_INDEX -Value "<value>"
# Set-Variable -Name SPLUNK_TOKEN_SECRET_ARN -Value "<value>"
# Invoke-Expression (Invoke-WebRequest -Uri "<path to this file>")
#
# Optionally pass extra arguments to Docker:
# Set-Variable -Name DOCKER_ARGS -Value "<value>"
# Set-Variable -Name TASK_CPU -Value "<value>"
# Set-Variable -Name TASK_MEMORY -Value "<value>"
# Set-Variable -Name TASK_PORT -Value "<value>"

$container_env_file = "${env:USERPROFILE}\${SERVICE_NAME}.env"
$container_stack_file = "${env:USERPROFILE}\${SERVICE_NAME}_stack.yaml"
$env:Path += ";C:\Program Files\Amazon\AWSCLIV2"

$environment_secret = aws secretsmanager get-secret-value --secret-id $SECRET_NAME | ConvertFrom-Json
if (-not $?) {
  Write-Error "Unable to fetch environment secret" -ErrorAction Stop
}
$environment_map = $environment_secret.SecretString | ConvertFrom-Json
$environment_map.psobject.Properties | ForEach-Object { $_.Name + "=" + $_.Value } | Out-File "$container_env_file" -Encoding ascii

$token_secret = aws secretsmanager get-secret-value --secret-id $SPLUNK_TOKEN_SECRET_ARN | ConvertFrom-Json
if (-not $?) {
  Write-Error "Unable to fetch Splunk token secret" -ErrorAction Stop
}
$splunk_token = $token_secret.SecretString

@"
version: '3.7'

services:
  container:
    image: ${DOCKER_REPO}:${DOCKER_TAG}
    env_file: ${container_env_file}
    $(if ("$TASK_PORT" -eq "") { "" } else { "ports:" })
    $(if ("$TASK_PORT" -eq "") { "" } else { "  - ${TASK_PORT}:${TASK_PORT}" })
    volumes:
      - type: bind
        source: ${env:USERPROFILE}\.aws
        target: C:\Users\ContainerAdministrator\.aws
        read_only: true
    isolation: process
    logging:
      driver: splunk
      options:
        splunk-token: "$splunk_token"
        splunk-url: "$splunk_url"
        splunk-index: "$splunk_index"
        splunk-format: raw
    deploy:
      mode: replicated
      replicas: 1
      update_config:
        order: start-first
      rollback_config:
        order: start-first
      resources:
        limits:
          cpus: "$(if ("$TASK_CPU" -eq "") { "0.25" } else { "$TASK_CPU" })"
          memory: "$(if ("$TASK_MEMORY" -eq "") { "256M" } else { "$TASK_MEMORY" })"
${DOCKER_ARGS}
"@ | Tee-Object -FilePath "$container_stack_file" | Out-Null

docker stack deploy --with-registry-auth -c "$container_stack_file" "$SERVICE_NAME"
if (-not $?) {
  Write-Error "Unable to start ${DOCKER_REPO}:${DOCKER_TAG}" -ErrorAction Stop
}
# Sleep 30s to give service time to start and stabilize, or crash >1 time
Start-Sleep -Seconds 30
docker service ps "${SERVICE_NAME}_container"
docker ps -f "name=${SERVICE_NAME}"
