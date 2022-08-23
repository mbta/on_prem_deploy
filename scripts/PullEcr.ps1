# # Usage
# Set-Variable -Name DOCKER_REPO -Value "<value>"
# Set-Variable -Name DOCKER_TAG -Value "<value>"
# Invoke-Expression (Invoke-WebRequest -Uri "<path to this file>")

$env:Path += ";C:\Program Files\Amazon\AWSCLIV2"

if ($DOCKER_REPO -match 'ecr\.[\w-]+\.amazonaws.com') {
    aws ecr get-login-password | docker login --username AWS --password-stdin "$DOCKER_REPO" 2>$null
}
docker pull "${DOCKER_REPO}:${DOCKER_TAG}"
if (-not $?) {
  Write-Error "Unable to pull ${DOCKER_REPO}:${DOCKER_TAG}" -ErrorAction Stop
}
