function GetSecretString()
{
    param (
        [Parameter(Mandatory)]
        [string]$SecretName
    )

    $SecretJson = aws secretsmanager get-secret-value --secret-id $SecretName | ConvertFrom-Json
    if (-not $?) {
        Write-Error "Unable to fetch secret $secretName" -ErrorAction Stop
    }
    $SecretJson.SecretString
}

function ContainerStack()
{
    param
    (
        [Parameter(Mandatory)]
        [string]$Image,

        [Parameter(Mandatory)]
        [string]$EnvFile,

        [Parameter(Mandatory)]
        [string]$SplunkToken,

        [Parameter(Mandatory)]
        [string]$SplunkUrl,

        [Parameter(Mandatory)]
        [string]$SplunkIndex,

        [string]$TaskCpu = "",
        [string]$TaskMemory = "",
        [string]$TaskPort = "",
        [int32]$Replicas = 1,
        [string]$UpdateOrder = "start-first",
        [string]$ExtraArgs = ""
    )

    $portStack = if ("$TaskPort" -eq "") {
        ""
    } else {
        @"
    ports:
      - ${TaskPort}:${TaskPort}
"@
    }

    @"
version: '3.7'

services:
  container:
    image: $image
    env_file: $envFile
${portStack}
    volumes:
      - type: bind
        source: ${env:USERPROFILE}\.aws
        target: C:\Users\ContainerAdministrator\.aws
        read_only: true
    isolation: process
    logging:
      driver: splunk
      options:
        splunk-token: "$splunkToken"
        splunk-url: "$splunkUrl"
        splunk-index: "$splunkIndex"
        splunk-format: raw
    deploy:
      mode: replicated
      replicas: $replicas
      update_config:
        order: $updateOrder
      rollback_config:
        order: $updateOrder
      resources:
        limits:
          cpus: "$(if ("$taskCpu" -eq "") { "0.25" } else { "$TaskCpu" })"
          memory: "$(if ("$taskMemory" -eq "") { "256M" } else { "$taskMemory" })"
${extraArgs}
"@
}
