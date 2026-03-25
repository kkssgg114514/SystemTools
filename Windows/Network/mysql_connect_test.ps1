<#
.SYNOPSIS
Test connectivity to a MySQL server using IP:Port as a command-line argument.

.DESCRIPTION
Usage: .\mysql_connect_test.ps1 192.168.1.100:3306
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($args.Count -eq 0) {
    Write-Output "Usage: .\$($MyInvocation.MyCommand.Name) IP:Port"
    Write-Output "Example: .\$($MyInvocation.MyCommand.Name) 192.168.1.100:3306"
    exit 1
}

$endpoint = $args[0]
if ($endpoint -match '^([^:]+):(\d+)$') {
    $mysqlIP = $matches[1]
    $mysqlPort = [int]$matches[2]
}
else {
    Write-Output "Error: Invalid format. Use IP:Port"
    exit 1
}

$tcpClient = $null

try {
    $tcpClient = [System.Net.Sockets.TcpClient]::new()
    $asyncResult = $tcpClient.BeginConnect($mysqlIP, $mysqlPort, $null, $null)
    if (-not $asyncResult.AsyncWaitHandle.WaitOne(5000, $false)) {
        throw "TCP timeout"
    }

    $tcpClient.EndConnect($asyncResult)
}
catch {
    Write-Output "TCP connection failed to ${mysqlIP}:${mysqlPort}"
    exit 1
}
finally {
    if ($null -ne $tcpClient) {
        $tcpClient.Dispose()
    }
}

Write-Output "Successfully connected to MySQL server at ${mysqlIP}:${mysqlPort}"
exit 0
