[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "common.ps1")

$baseBoards = @(Get-CimInstance -ClassName Win32_BaseBoard)
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("=== Motherboard Information ===")

if ($baseBoards.Count -eq 0) {
    $lines.Add("No motherboard information found.")
}
else {
    foreach ($board in $baseBoards) {
        $lines.Add(("Manufacturer  : {0}" -f (Join-Value $board.Manufacturer)))
        $lines.Add(("Product       : {0}" -f (Join-Value $board.Product)))
        $lines.Add(("Version       : {0}" -f (Join-Value $board.Version)))
        $lines.Add(("Serial Number : {0}" -f (Join-Value $board.SerialNumber)))
        $lines.Add("")
    }
}

$lines | Write-Output
