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

# NOTE: requires that the functions from Helpers.ps1 are sourced first.
# . .\Helpers.ps1
# .\docker_stack_deploy.ps1

$container_stack_file = "${env:USERPROFILE}\${SERVICE_NAME}_stack.yaml"
$env:Path += ";C:\Program Files\Amazon\AWSCLIV2"

$environment_map = GetSecretString -SecretName $SECRET_NAME | ConvertFrom-Json

$splunk_token = GetSecretString -SecretName $SPLUNK_TOKEN_SECRET_ARN

ContainerStack `
    -Service "${SERVICE_NAME}" `
    -Image "${DOCKER_REPO}:${DOCKER_TAG}" `
    -Environment $environment_map.psobject.Properties `
    -splunkToken $splunk_token `
    -splunkUrl $SPLUNK_URL `
    -splunkIndex $SPLUNK_INDEX `
    -taskCpu $TASK_CPU `
    -taskMemory $TASK_MEMORY `
    -taskPort $TASK_PORT `
    -extraArgs $DOCKER_ARGS `
> "$container_stack_file"

docker stack deploy --with-registry-auth -c "$container_stack_file" "$SERVICE_NAME"
if (-not $?) {
  Write-Error "Unable to start ${DOCKER_REPO}:${DOCKER_TAG}" -ErrorAction Stop
}

docker service update "${SERVICE_NAME}_container"
if (-not $?) {
  Write-Error "Unable to update ${DOCKER_REPO}:${DOCKER_TAG}" -ErrorAction Stop
}

docker service ps "${SERVICE_NAME}_container"
