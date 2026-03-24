[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "common.ps1")

$memoryModules = @(Get-CimInstance -ClassName Win32_PhysicalMemory | Sort-Object DeviceLocator, BankLabel)
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("=== Memory Information ===")

if ($memoryModules.Count -eq 0) {
    $lines.Add("No memory module information found.")
}
else {
    foreach ($memory in $memoryModules) {
        $capacityText = if ($null -ne $memory.Capacity -and [double]$memory.Capacity -gt 0) {
            Format-Bytes -Bytes ([double]$memory.Capacity)
        }
        else {
            "N/A"
        }

        $slot = if (-not [string]::IsNullOrWhiteSpace([string]$memory.DeviceLocator)) {
            [string]$memory.DeviceLocator
        }
        else {
            Join-Value $memory.BankLabel
        }

        $lines.Add(("Slot          : {0}" -f $slot))
        $lines.Add(("Manufacturer  : {0}" -f (Join-Value $memory.Manufacturer)))
        $lines.Add(("Part Number   : {0}" -f (Join-Value $memory.PartNumber)))
        $lines.Add(("Capacity      : {0}" -f $capacityText))
        $lines.Add(("Speed         : {0} MHz" -f (Join-Value $memory.Speed)))
        $lines.Add("")
    }
}

$lines | Write-Output
