[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "common.ps1")

$portStatuses = @(Get-CommonPortStatuses)
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("=== Common Port Status ===")

if ($portStatuses.Count -eq 0) {
    $lines.Add("No port status information found.")
}
else {
    foreach ($portStatus in $portStatuses) {
        $statusText = if ($portStatus.IsListening) { "Listening" } else { "Free" }
        $lines.Add(("{0} ({1}) : {2}" -f $portStatus.Service, $portStatus.Port, $statusText))
        $lines.Add(("Bindings      : {0}" -f $portStatus.BindingsText))
        $lines.Add("")
    }
}

$lines | Write-Output
