[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Format-Bytes {
    param(
        [Parameter(Mandatory = $true)]
        [double]$Bytes
    )

    if ($Bytes -ge 1TB) {
        return "{0:N2} TB" -f ($Bytes / 1TB)
    }

    if ($Bytes -ge 1GB) {
        return "{0:N2} GB" -f ($Bytes / 1GB)
    }

    if ($Bytes -ge 1MB) {
        return "{0:N2} MB" -f ($Bytes / 1MB)
    }

    return "{0:N2} KB" -f ($Bytes / 1KB)
}

function Format-Percent {
    param(
        [Parameter(Mandatory = $true)]
        [double]$Value
    )

    return "{0:N1}%" -f $Value
}

function Join-Value {
    param(
        [AllowNull()]
        [object]$Value,
        [string]$Separator = ", "
    )

    if ($null -eq $Value) {
        return "N/A"
    }

    if ($Value -is [System.Array]) {
        $items = @($Value | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
        if ($items.Count -eq 0) {
            return "N/A"
        }

        return ($items -join $Separator)
    }

    $text = [string]$Value
    if ([string]::IsNullOrWhiteSpace($text)) {
        return "N/A"
    }

    return $text.Trim()
}

function Get-ProcessNameById {
    param(
        [Parameter(Mandatory = $true)]
        [int]$ProcessId
    )

    try {
        return (Get-Process -Id $ProcessId -ErrorAction Stop).ProcessName
    }
    catch {
        return "Unknown"
    }
}

function Get-GpuCounterSummary {
    $engineData = @(Get-CimInstance -ClassName Win32_PerfFormattedData_GPUPerformanceCounters_GPUEngine -ErrorAction SilentlyContinue)
    $memoryData = @(Get-CimInstance -ClassName Win32_PerfFormattedData_GPUPerformanceCounters_GPUAdapterMemory -ErrorAction SilentlyContinue)
    $physicalIndices = New-Object System.Collections.Generic.HashSet[string]

    foreach ($entry in $engineData) {
        $match = [regex]::Match([string]$entry.Name, 'phys_(\d+)')
        if ($match.Success) {
            [void]$physicalIndices.Add($match.Groups[1].Value)
        }
    }

    foreach ($entry in $memoryData) {
        $match = [regex]::Match([string]$entry.Name, 'phys_(\d+)')
        if ($match.Success) {
            [void]$physicalIndices.Add($match.Groups[1].Value)
        }
    }

    $summaries = @()

    foreach ($physicalIndex in ($physicalIndices | Sort-Object { [int]$_ })) {
        $engineMatches = @($engineData | Where-Object { $_.Name -match "phys_$physicalIndex" })
        $memoryMatches = @($memoryData | Where-Object { $_.Name -match "phys_$physicalIndex" })

        $busiestEnginePercent = 0.0
        if ($engineMatches.Count -gt 0) {
            $busiestEnginePercent = ($engineMatches | Measure-Object -Property UtilizationPercentage -Maximum).Maximum
        }

        $dedicatedUsage = 0.0
        $sharedUsage = 0.0
        $totalCommitted = 0.0

        if ($memoryMatches.Count -gt 0) {
            $dedicatedUsage = ($memoryMatches | Measure-Object -Property DedicatedUsage -Sum).Sum
            $sharedUsage = ($memoryMatches | Measure-Object -Property SharedUsage -Sum).Sum
            $totalCommitted = ($memoryMatches | Measure-Object -Property TotalCommitted -Sum).Sum
        }

        $summaries += [PSCustomObject]@{
            PhysicalIndex        = [int]$physicalIndex
            BusiestEnginePercent = [double]$busiestEnginePercent
            DedicatedUsage       = [double]$dedicatedUsage
            SharedUsage          = [double]$sharedUsage
            TotalCommitted       = [double]$totalCommitted
        }
    }

    return $summaries
}

function Get-CommonPortStatuses {
    $portMap = [ordered]@{
        "3306" = "MySQL"
        "6379" = "Redis"
        "7474" = "Neo4j HTTP"
        "7687" = "Neo4j Bolt"
        "9000" = "MinIO API"
        "9001" = "MinIO Console"
    }

    $listenConnections = @(Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue)
    $results = @()

    foreach ($portKey in $portMap.Keys) {
        $port = [int]$portKey
        $portConnections = @($listenConnections | Where-Object { $_.LocalPort -eq $port } | Sort-Object LocalAddress, OwningProcess)

        if ($portConnections.Count -eq 0) {
            $results += [PSCustomObject]@{
                Port         = $port
                Service      = [string]$portMap[$portKey]
                IsListening  = $false
                BindingsText = "Not in use"
            }

            continue
        }

        $bindings = foreach ($portConnection in $portConnections) {
            $processName = Get-ProcessNameById -ProcessId $portConnection.OwningProcess
            "{0} ({1}:{2})" -f $processName, $portConnection.LocalAddress, $portConnection.OwningProcess
        }

        $results += [PSCustomObject]@{
            Port         = $port
            Service      = [string]$portMap[$portKey]
            IsListening  = $true
            BindingsText = ($bindings -join "; ")
        }
    }

    return $results
}
