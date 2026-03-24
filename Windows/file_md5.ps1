[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$resolvedPath = Resolve-Path -LiteralPath $Path
$item = Get-Item -LiteralPath $resolvedPath

if ($item.PSIsContainer) {
    Write-Error "Directory input is not supported. Please provide a file path."
    exit 1
}

$fileHash = Get-FileHash -LiteralPath $item.FullName -Algorithm MD5
Write-Output $fileHash.Hash
