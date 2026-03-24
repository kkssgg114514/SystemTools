[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "common.ps1")

$computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
$operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("=== System Overview ===")
$lines.Add(("Computer Name : {0}" -f $env:COMPUTERNAME))
$lines.Add(("System Model  : {0}" -f (Join-Value $computerSystem.Model)))
$lines.Add(("Manufacturer  : {0}" -f (Join-Value $computerSystem.Manufacturer)))
$lines.Add(("System Type   : {0}" -f (Join-Value $computerSystem.SystemType)))
$lines.Add(("User          : {0}" -f (Join-Value $computerSystem.UserName)))
$lines.Add(("OS            : {0}" -f (Join-Value $operatingSystem.Caption)))
$lines.Add(("Version       : {0}" -f (Join-Value $operatingSystem.Version)))
$lines.Add(("Build Number  : {0}" -f (Join-Value $operatingSystem.BuildNumber)))
$lines.Add(("Install Date  : {0}" -f $operatingSystem.InstallDate.ToString("yyyy-MM-dd HH:mm:ss")))
$lines.Add(("Last Boot     : {0}" -f $operatingSystem.LastBootUpTime.ToString("yyyy-MM-dd HH:mm:ss")))
$lines.Add("")

$lines | Write-Output
