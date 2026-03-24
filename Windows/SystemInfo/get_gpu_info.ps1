[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "common.ps1")

$videoControllers = @(Get-CimInstance -ClassName Win32_VideoController | Sort-Object Name)
$gpuCounters = @(Get-GpuCounterSummary)
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("=== GPU Information ===")

if ($videoControllers.Count -eq 0) {
    $lines.Add("No GPU information found.")
}
else {
    for ($i = 0; $i -lt $videoControllers.Count; $i++) {
        $gpu = $videoControllers[$i]
        $gpuCounter = $gpuCounters | Where-Object { $_.PhysicalIndex -eq $i } | Select-Object -First 1

        $adapterRamText = if ($null -ne $gpu.AdapterRAM -and [double]$gpu.AdapterRAM -gt 0) {
            Format-Bytes -Bytes ([double]$gpu.AdapterRAM)
        }
        else {
            "N/A"
        }

        $lines.Add(("GPU #{0}        : {1}" -f $i, (Join-Value $gpu.Name)))
        $lines.Add(("Video Processor: {0}" -f (Join-Value $gpu.VideoProcessor)))
        $lines.Add(("Driver Version : {0}" -f (Join-Value $gpu.DriverVersion)))
        $lines.Add(("Adapter RAM    : {0}" -f $adapterRamText))

        if ($null -ne $gpuCounter) {
            $lines.Add(("GPU Usage      : {0}" -f (Format-Percent -Value $gpuCounter.BusiestEnginePercent)))
            $lines.Add(("Dedicated VRAM : {0}" -f (Format-Bytes -Bytes $gpuCounter.DedicatedUsage)))
            $lines.Add(("Shared GPU Mem : {0}" -f (Format-Bytes -Bytes $gpuCounter.SharedUsage)))
            $lines.Add(("Total Committed: {0}" -f (Format-Bytes -Bytes $gpuCounter.TotalCommitted)))
        }
        else {
            $lines.Add("GPU Usage      : N/A")
            $lines.Add("Dedicated VRAM : N/A")
            $lines.Add("Shared GPU Mem : N/A")
            $lines.Add("Total Committed: N/A")
        }

        $lines.Add("")
    }
}

$lines | Write-Output
