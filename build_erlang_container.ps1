param(
    [string]$ImageNameRoot="",

    [Parameter(Mandatory)]
    [string]$WindowsVersion,

    [Parameter(Mandatory)]
    [string]$ErlangVersion,

    [switch]$Force=$false
)
$erlimage="${ImageNameRoot}erlang"
$erltag="${ErlangVersion}-windows-${WindowsVersion}"

docker manifest inspect "${erlimage}:${erltag}" | Out-Null
if (-not $Force -and $?) {
    Write-Output "Skipping ${erlimage}:${erltag}, already exists."
} else {
  docker build docker -f docker/Dockerfile.erlang `
    --build-arg BUILD_IMAGE="mcr.microsoft.com/windows/servercore:${WindowsVersion}" `
    --build-arg FROM_IMAGE="mcr.microsoft.com/windows/servercore:${WindowsVersion}" `
    --build-arg OTP_VERSION=$ErlangVersion `
    --tag "${erlimage}:${erltag}"

  docker push "${erlimage}:${erltag}"
}
