[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "common.ps1")

$processors = @(Get-CimInstance -ClassName Win32_Processor)
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("=== CPU Information ===")

if ($processors.Count -eq 0) {
    $lines.Add("No CPU information found.")
}
else {
    foreach ($cpu in $processors) {
        $lines.Add(("CPU           : {0}" -f (Join-Value $cpu.Name)))
        $lines.Add(("Cores         : {0}" -f (Join-Value $cpu.NumberOfCores)))
        $lines.Add(("Logical CPUs  : {0}" -f (Join-Value $cpu.NumberOfLogicalProcessors)))
        $lines.Add(("Max Clock     : {0} MHz" -f (Join-Value $cpu.MaxClockSpeed)))
        $lines.Add("")
    }
}

$lines | Write-Output
