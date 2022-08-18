# on_prem_deploy
Support scripts for deploying to on-prem servers

## Testing

PowerShell tests are written with [Pester](https://pester.dev).

To run them from a Windows server:

``` powershell
.\InstallTestDependencies.ps1
.\RunPesterTests.ps1
```

To run them from a non-Windows server:

``` sh
docker build -f Dockerfile.test .
```

