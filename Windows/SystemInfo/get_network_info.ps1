[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "common.ps1")

$networkConfigs = @(Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled = True" | Sort-Object Description)
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("=== Network Information ===")

if ($networkConfigs.Count -eq 0) {
    $lines.Add("No active network adapters found.")
}
else {
    foreach ($adapter in $networkConfigs) {
        $lines.Add(("Adapter       : {0}" -f (Join-Value $adapter.Description)))
        $lines.Add(("MAC Address   : {0}" -f (Join-Value $adapter.MACAddress)))
        $lines.Add(("IP Address    : {0}" -f (Join-Value $adapter.IPAddress)))
        $lines.Add(("Subnet Mask   : {0}" -f (Join-Value $adapter.IPSubnet)))
        $lines.Add(("Gateway       : {0}" -f (Join-Value $adapter.DefaultIPGateway)))
        $lines.Add(("DNS Server    : {0}" -f (Join-Value $adapter.DNSServerSearchOrder)))
        $lines.Add("")
    }
}

$lines | Write-Output
