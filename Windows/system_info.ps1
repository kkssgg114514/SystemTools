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
        if ($entry.Name -match 'phys_(\d+)') {
            [void]$physicalIndices.Add($matches[1])
        }
    }

    foreach ($entry in $memoryData) {
        if ($entry.Name -match 'phys_(\d+)') {
            [void]$physicalIndices.Add($matches[1])
        }
    }

    $summaries = @()

    foreach ($physicalIndex in ($physicalIndices | Sort-Object {[int]$_})) {
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

function Get-PortStatus {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$PortMap
    )

    $listenConnections = @(Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue)
    $results = @()

    foreach ($port in ($PortMap.Keys | Sort-Object {[int]$_})) {
        $matches = @($listenConnections | Where-Object { $_.LocalPort -eq [int]$port } | Sort-Object LocalAddress, OwningProcess)

        if ($matches.Count -eq 0) {
            $results += [PSCustomObject]@{
                Port         = [int]$port
                Service      = [string]$PortMap[$port]
                IsListening  = $false
                BindingsText = "Not in use"
            }

            continue
        }

        $bindings = foreach ($match in $matches) {
            $processName = Get-ProcessNameById -ProcessId $match.OwningProcess
            "{0} ({1}:{2})" -f $processName, $match.LocalAddress, $match.OwningProcess
        }

        $results += [PSCustomObject]@{
            Port         = [int]$port
            Service      = [string]$PortMap[$port]
            IsListening  = $true
            BindingsText = ($bindings -join "; ")
        }
    }

    return $results
}

$computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
$operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
$baseBoards = @(Get-CimInstance -ClassName Win32_BaseBoard)
$processors = @(Get-CimInstance -ClassName Win32_Processor)
$videoControllers = @(Get-CimInstance -ClassName Win32_VideoController | Sort-Object Name)
$diskDrives = @(Get-CimInstance -ClassName Win32_DiskDrive | Sort-Object Index)
$memoryModules = @(Get-CimInstance -ClassName Win32_PhysicalMemory | Sort-Object DeviceLocator, BankLabel)
$networkConfigs = @(Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled = True" | Sort-Object Description)
$logicalDisks = @(Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3" | Sort-Object DeviceID)
$gpuCounters = @(Get-GpuCounterSummary)
$portStatuses = @(Get-PortStatus -PortMap @{
    3306 = "MySQL"
    6379 = "Redis"
    7474 = "Neo4j HTTP"
    7687 = "Neo4j Bolt"
    9000 = "MinIO API"
    9001 = "MinIO Console"
})

$cpuLoad = 0.0
if ($processors.Count -gt 0) {
    $cpuLoad = ($processors | Measure-Object -Property LoadPercentage -Average).Average
}

$totalMemoryBytes = [double]$operatingSystem.TotalVisibleMemorySize * 1KB
$freeMemoryBytes = [double]$operatingSystem.FreePhysicalMemory * 1KB
$usedMemoryBytes = $totalMemoryBytes - $freeMemoryBytes
$memoryUsagePercent = if ($totalMemoryBytes -gt 0) {
    ($usedMemoryBytes / $totalMemoryBytes) * 100
}
else {
    0
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("=== System Information ===")
$lines.Add(("Computer Name : {0}" -f $env:COMPUTERNAME))
$lines.Add(("System Model  : {0}" -f (Join-Value $computerSystem.Model)))
$lines.Add(("Manufacturer  : {0}" -f (Join-Value $computerSystem.Manufacturer)))
$lines.Add(("System Type   : {0}" -f (Join-Value $computerSystem.SystemType)))
$lines.Add(("User          : {0}" -f (Join-Value $computerSystem.UserName)))
$lines.Add("")

$lines.Add("=== Windows Version ===")
$lines.Add(("OS            : {0}" -f (Join-Value $operatingSystem.Caption)))
$lines.Add(("Version       : {0}" -f (Join-Value $operatingSystem.Version)))
$lines.Add(("Build Number  : {0}" -f (Join-Value $operatingSystem.BuildNumber)))
$lines.Add(("Install Date  : {0}" -f $operatingSystem.InstallDate.ToString("yyyy-MM-dd HH:mm:ss")))
$lines.Add(("Last Boot     : {0}" -f $operatingSystem.LastBootUpTime.ToString("yyyy-MM-dd HH:mm:ss")))
$lines.Add("")

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

$lines.Add("=== GPU Information ===")
if ($videoControllers.Count -eq 0) {
    $lines.Add("No GPU information found.")
}
else {
    for ($i = 0; $i -lt $videoControllers.Count; $i++) {
        $gpu = $videoControllers[$i]
        $gpuCounter = $gpuCounters | Where-Object { $_.PhysicalIndex -eq $i } | Select-Object -First 1
        $adapterRamText = if ($null -ne $gpu.AdapterRAM -and [double]$gpu.AdapterRAM -gt 0) {
            Format-Bytes -Bytes ([double]$gpu.AdapterRAM)
        }
        else {
            "N/A"
        }

        $lines.Add(("GPU #{0}        : {1}" -f $i, (Join-Value $gpu.Name)))
        $lines.Add(("Video Processor: {0}" -f (Join-Value $gpu.VideoProcessor)))
        $lines.Add(("Driver Version : {0}" -f (Join-Value $gpu.DriverVersion)))
        $lines.Add(("Adapter RAM    : {0}" -f $adapterRamText))

        if ($null -ne $gpuCounter) {
            $lines.Add(("GPU Usage      : {0}" -f (Format-Percent -Value $gpuCounter.BusiestEnginePercent)))
            $lines.Add(("Dedicated VRAM : {0}" -f (Format-Bytes -Bytes $gpuCounter.DedicatedUsage)))
            $lines.Add(("Shared GPU Mem : {0}" -f (Format-Bytes -Bytes $gpuCounter.SharedUsage)))
            $lines.Add(("Total Committed: {0}" -f (Format-Bytes -Bytes $gpuCounter.TotalCommitted)))
        }
        else {
            $lines.Add("GPU Usage      : N/A")
            $lines.Add("Dedicated VRAM : N/A")
            $lines.Add("Shared GPU Mem : N/A")
            $lines.Add("Total Committed: N/A")
        }

        $lines.Add("")
    }
}

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

$lines.Add("=== Memory Information ===")
if ($memoryModules.Count -eq 0) {
    $lines.Add("No memory module information found.")
}
else {
    foreach ($memory in $memoryModules) {
        $capacityText = if ($null -ne $memory.Capacity -and [double]$memory.Capacity -gt 0) {
            Format-Bytes -Bytes ([double]$memory.Capacity)
        }
        else {
            "N/A"
        }

        $slot = if (-not [string]::IsNullOrWhiteSpace([string]$memory.DeviceLocator)) {
            [string]$memory.DeviceLocator
        }
        else {
            Join-Value $memory.BankLabel
        }

        $lines.Add(("Slot          : {0}" -f $slot))
        $lines.Add(("Manufacturer  : {0}" -f (Join-Value $memory.Manufacturer)))
        $lines.Add(("Part Number   : {0}" -f (Join-Value $memory.PartNumber)))
        $lines.Add(("Capacity      : {0}" -f $capacityText))
        $lines.Add(("Speed         : {0} MHz" -f (Join-Value $memory.Speed)))
        $lines.Add("")
    }
}

$lines.Add("=== Resource Usage (Sample Time) ===")
$lines.Add(("Sample Time   : {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")))
$lines.Add(("CPU Usage     : {0}" -f (Format-Percent -Value $cpuLoad)))
$lines.Add(("Memory Usage  : {0} / {1} ({2})" -f (Format-Bytes -Bytes $usedMemoryBytes), (Format-Bytes -Bytes $totalMemoryBytes), (Format-Percent -Value $memoryUsagePercent)))

if ($logicalDisks.Count -eq 0) {
    $lines.Add("Disk Usage     : No local logical disks found.")
}
else {
    foreach ($logicalDisk in $logicalDisks) {
        if ($null -eq $logicalDisk.Size -or [double]$logicalDisk.Size -le 0) {
            $lines.Add(("Disk Usage    : {0} size unavailable" -f $logicalDisk.DeviceID))
            continue
        }

        $logicalDiskSize = [double]$logicalDisk.Size
        $logicalDiskFree = [double]$logicalDisk.FreeSpace
        $logicalDiskUsed = $logicalDiskSize - $logicalDiskFree
        $logicalDiskUsagePercent = ($logicalDiskUsed / $logicalDiskSize) * 100
        $lines.Add(("Disk Usage    : {0} {1} / {2} ({3})" -f $logicalDisk.DeviceID, (Format-Bytes -Bytes $logicalDiskUsed), (Format-Bytes -Bytes $logicalDiskSize), (Format-Percent -Value $logicalDiskUsagePercent)))
    }
}

$lines.Add("")
$lines.Add("=== Common Port Status ===")
if ($portStatuses.Count -eq 0) {
    $lines.Add("No port status information found.")
}
else {
    foreach ($portStatus in $portStatuses) {
        $statusText = if ($portStatus.IsListening) { "Listening" } else { "Free" }
        $lines.Add(("{0} ({1}) : {2}" -f $portStatus.Service, $portStatus.Port, $statusText))
        $lines.Add(("Bindings      : {0}" -f $portStatus.BindingsText))
        $lines.Add("")
    }
}

$lines | Write-Output
