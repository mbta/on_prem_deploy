$ErrorActionPreference = "Stop"

$config = New-PesterConfiguration
$config.Run.Exit = $true
$config.Run.Path = '*.Tests.ps1'
$config.Output.Verbosity = 'Detailed'
$config.Output.CIFormat = 'Auto'

Invoke-Pester -Configuration $config
