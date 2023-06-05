param(
    [string]$ImageNameRoot="",

    [Parameter(Mandatory)]
    [string]$WindowsVersion,

    [Parameter(Mandatory)]
    [string]$ErlangVersion,

    [Parameter(Mandatory)]
    [string]$ElixirVersion,

    [switch]$Force=$false

)

$erlimage="${ImageNameRoot}erlang"
$erltag="${ErlangVersion}-windows-${WindowsVersion}"
$elixirimage="${ImageNameRoot}elixir"
$elixirtag="${ElixirVersion}-erlang-${erltag}"
$ElixirZip="Precompiled"

if ([System.Version]$ElixirVersion -ge [System.Version]"1.14.0") {
    # With Elixir 1.14.0, the releases are precompiled for the specific Erlang version.
    $ErlangMajorVersion=$ErlangVersion.split(".")[0]
    if ([System.Version]$ElixirVersion -lt [System.Version]"1.15.0" -and $ErlangMajorVersion -gt "25") {
        # Erlang 1.14 is not precompiled for Erlang 26, so we use the Erlang 25 pre-compiled version there.
        $ErlangMajorVersion="25"
    }
    $ElixirZip="elixir-otp-$ErlangMajorVersion"
}

docker manifest inspect "${elixirimage}:${elixirtag}" | Out-Null
if (-not $Force -and $?) {
    Write-Output "Skipping ${elixirimage}:${elixirtag}, already exists."
} else {
  docker build docker -f docker/Dockerfile.elixir `
    --build-arg BUILD_IMAGE="mcr.microsoft.com/windows/servercore:${WindowsVersion}" `
    --build-arg FROM_IMAGE="${erlimage}:${erltag}" `
    --build-arg ELIXIR_VERSION="$ElixirVersion" `
    --build-arg ELIXIR_ZIP="$ElixirZip" `
    --tag "${elixirimage}:${elixirtag}"

  docker push "${elixirimage}:${elixirtag}"
}
