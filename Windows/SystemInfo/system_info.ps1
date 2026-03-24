[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$componentScripts = @(
    "get_system_overview.ps1"
    "get_motherboard_info.ps1"
    "get_network_info.ps1"
    "get_cpu_info.ps1"
    "get_gpu_info.ps1"
    "get_disk_info.ps1"
    "get_memory_info.ps1"
    "get_resource_usage.ps1"
    "get_common_port_status.ps1"
)

$lines = New-Object System.Collections.Generic.List[string]

foreach ($componentScript in $componentScripts) {
    $componentPath = Join-Path $scriptDir $componentScript
    $componentOutput = @(& $componentPath)

    foreach ($line in $componentOutput) {
        $lines.Add([string]$line)
    }
}

$lines | Write-Output
