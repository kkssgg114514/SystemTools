<#
.SYNOPSIS
Test connectivity to a MinIO server using IP:Port as a command-line argument.

.DESCRIPTION
Usage: .\minio_connect_test.ps1 192.168.1.100:9000
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($args.Count -eq 0) {
    Write-Output "Usage: .\$($MyInvocation.MyCommand.Name) IP:Port"
    Write-Output "Example: .\$($MyInvocation.MyCommand.Name) 192.168.1.100:9000"
    exit 1
}

$endpoint = $args[0]
if ($endpoint -match '^([^:]+):(\d+)$') {
    $minioIP = $matches[1]
    $minioPort = [int]$matches[2]
}
else {
    Write-Output "Error: Invalid format. Use IP:Port"
    exit 1
}

$minioUrl = "http://${minioIP}:${minioPort}"
$healthUrl = "${minioUrl}/minio/health/live"

try {
    $tcpClient = [System.Net.Sockets.TcpClient]::new()
    $asyncResult = $tcpClient.BeginConnect($minioIP, $minioPort, $null, $null)
    if (-not $asyncResult.AsyncWaitHandle.WaitOne(5000, $false)) {
        throw "TCP timeout"
    }

    $tcpClient.EndConnect($asyncResult)
}
catch {
    Write-Output "TCP connection failed to ${minioIP}:${minioPort}"
    exit 1
}
finally {
    if ($null -ne $tcpClient) {
        $tcpClient.Dispose()
    }
}

try {
    $response = Invoke-WebRequest -Uri $healthUrl -Method Get -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -ne 200) {
        Write-Output "MinIO service unavailable at ${minioUrl}"
        exit 1
    }
}
catch {
    Write-Output "MinIO service unavailable at ${minioUrl}"
    exit 1
}

Write-Output "Successfully connected to MinIO server at ${minioUrl}"
exit 0
