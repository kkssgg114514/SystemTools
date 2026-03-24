[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "common.ps1")

$operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
$processors = @(Get-CimInstance -ClassName Win32_Processor)
$logicalDisks = @(Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3" | Sort-Object DeviceID)

$cpuLoad = 0.0
if ($processors.Count -gt 0) {
    $cpuLoad = ($processors | Measure-Object -Property LoadPercentage -Average).Average
}

$totalMemoryBytes = [double]$operatingSystem.TotalVisibleMemorySize * 1KB
$freeMemoryBytes = [double]$operatingSystem.FreePhysicalMemory * 1KB
$usedMemoryBytes = $totalMemoryBytes - $freeMemoryBytes
$memoryUsagePercent = if ($totalMemoryBytes -gt 0) {
    ($usedMemoryBytes / $totalMemoryBytes) * 100
}
else {
    0
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("=== Resource Usage (Sample Time) ===")
$lines.Add(("Sample Time   : {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$lines.Add(("CPU Usage     : {0}" -f (Format-Percent -Value $cpuLoad)))
$lines.Add(("Memory Usage  : {0} / {1} ({2})" -f (Format-Bytes -Bytes $usedMemoryBytes), (Format-Bytes -Bytes $totalMemoryBytes), (Format-Percent -Value $memoryUsagePercent)))

if ($logicalDisks.Count -eq 0) {
    $lines.Add("Disk Usage    : No local logical disks found.")
}
else {
    foreach ($logicalDisk in $logicalDisks) {
        if ($null -eq $logicalDisk.Size -or [double]$logicalDisk.Size -le 0) {
            $lines.Add(("Disk Usage    : {0} size unavailable" -f $logicalDisk.DeviceID))
            continue
        }

        $logicalDiskSize = [double]$logicalDisk.Size
        $logicalDiskFree = [double]$logicalDisk.FreeSpace
        $logicalDiskUsed = $logicalDiskSize - $logicalDiskFree
        $logicalDiskUsagePercent = ($logicalDiskUsed / $logicalDiskSize) * 100
        $lines.Add(("Disk Usage    : {0} {1} / {2} ({3})" -f $logicalDisk.DeviceID, (Format-Bytes -Bytes $logicalDiskUsed), (Format-Bytes -Bytes $logicalDiskSize), (Format-Percent -Value $logicalDiskUsagePercent)))
    }
}

$lines.Add("")
$lines | Write-Output
