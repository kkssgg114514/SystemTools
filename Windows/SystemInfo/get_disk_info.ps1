[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "common.ps1")

$diskDrives = @(Get-CimInstance -ClassName Win32_DiskDrive | Sort-Object Index)
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("=== Disk Information ===")

if ($diskDrives.Count -eq 0) {
    $lines.Add("No disk information found.")
}
else {
    foreach ($disk in $diskDrives) {
        $sizeText = if ($null -ne $disk.Size -and [double]$disk.Size -gt 0) {
            Format-Bytes -Bytes ([double]$disk.Size)
        }
        else {
            "N/A"
        }

        $lines.Add(("Disk #{0}      : {1}" -f $disk.Index, (Join-Value $disk.Model)))
        $lines.Add(("Interface     : {0}" -f (Join-Value $disk.InterfaceType)))
        $lines.Add(("Media Type    : {0}" -f (Join-Value $disk.MediaType)))
        $lines.Add(("Size          : {0}" -f $sizeText))
        $lines.Add("")
    }
}

$lines | Write-Output
