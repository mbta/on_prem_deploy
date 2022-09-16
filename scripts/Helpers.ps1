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

function EnvironmentConfig()
{
    param
    (
        [Parameter(Mandatory)]
        [object]$Environment
    )
    $rows = $Environment | ForEach-Object {
        $escapedValue = $_.Value.replace("`n", "\n").replace("`r", "\r")
        $_.Name + "=" + $escapedValue
    }
    $rows -Join "`r`n"
}

function ContainerStack()
{
    param
    (
        [Parameter(Mandatory)]
        [string]$Service,

        [Parameter(Mandatory)]
        [string]$Image,

        [Parameter(Mandatory)]
        [string]$SplunkToken,

        [Parameter(Mandatory)]
        [string]$SplunkUrl,

        [Parameter(Mandatory)]
        [string]$SplunkIndex,

        [object]$Environment = @{},
        [string]$TaskCpu = "",
        [string]$TaskMemory = "",
        [string]$TaskPort = "",
        [int32]$Replicas = 1,
        [string]$UpdateOrder = "start-first",
        [string]$ExtraArgs = ""
    )

    $environmentStack =
    @"
    environment:
$(
$environmentRows = $Environment.GetEnumerator() | ForEach-Object {
    "      $($_.Name): `"$($_.Value.replace("`n", "\n"))`""
}
$environmentRows -Join "`n"
)
"@
    $portStack = if ("$TaskPort" -eq "") {
        ""
    } else {
        $portRows = $TaskPort.split(" ") `
          | ForEach-Object { "      - ${_}:${_}" }
        @"
    ports:
$($portRows -Join "`n")
"@
    }

    @"
version: '3.7'

services:
  container:
    image: $image
${environmentStack}
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
        splunk-source: "$Service"
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
