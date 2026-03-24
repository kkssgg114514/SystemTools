[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Text,

    [Parameter(Position = 1)]
    [string]$Salt = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$inputText = $Text + $Salt
$bytes = [System.Text.Encoding]::UTF8.GetBytes($inputText)
$sha256 = [System.Security.Cryptography.SHA256]::Create()

try {
    $hashBytes = $sha256.ComputeHash($bytes)
    $hashString = [System.BitConverter]::ToString($hashBytes).Replace("-", "")
    Write-Output $hashString
}
finally {
    $sha256.Dispose()
}
