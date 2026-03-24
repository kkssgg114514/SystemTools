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
$md5 = [System.Security.Cryptography.MD5]::Create()

try {
    $hashBytes = $md5.ComputeHash($bytes)
    $hashString = [System.BitConverter]::ToString($hashBytes).Replace("-", "")
    Write-Output $hashString
}
finally {
    $md5.Dispose()
}
