param(
    [string]$ImageNameRoot="",

    [Parameter(Mandatory)]
    [string]$WindowsVersion,

    [Parameter(Mandatory)]
    [string]$ErlangVersion,

    [Parameter(Mandatory)]
    [string]$ElixirVersion

)

$erlimage="${ImageNameRoot}erlang"
$erltag="${ErlangVersion}-windows-${WindowsVersion}"
$elixirimage="${ImageNameRoot}elixir"
$elixirtag="${ElixirVersion}-erlang-${erltag}"

docker manifest inspect "${elixirimage}:${elixirtag}" | Out-Null
if ($?) {
    Write-Output "Skipping ${elixirimage}:${elixirtag}, already exists."
} else {
  docker build docker -f docker/Dockerfile.elixir `
    --build-arg BUILD_IMAGE="mcr.microsoft.com/windows/servercore:${WindowsVersion}" `
    --build-arg FROM_IMAGE="${erlimage}:${erltag}" `
    --build-arg ELIXIR_VERSION=$ElixirVersion `
    --tag "${elixirimage}:${elixirtag}"

  docker push "${elixirimage}:${elixirtag}"
}
