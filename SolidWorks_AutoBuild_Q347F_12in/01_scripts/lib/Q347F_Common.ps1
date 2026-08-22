function Write-RunLog {
    param(
        [Parameter(Mandatory)][string]$Step,
        [Parameter(Mandatory)][string]$Object,
        [Parameter(Mandatory)][int]$Percent,
        [Parameter(Mandatory)][ValidateSet('WAITING','RUNNING','PASS','WARN','FAIL','BLOCKED','SKIP')][string]$Status,
        [Parameter(Mandatory)][string]$Message
    )
    $script:CurrentStep = $Step
    $script:CurrentObject = $Object
    $script:CurrentPercent = [Math]::Max(0, [Math]::Min(100, $Percent))
    $ts = Get-Date -Format 'HH:mm:ss'
    $line = '[{0}][{1}][{2}][{3:00}%][{4}] {5}' -f $ts, $Step, $Object, $script:CurrentPercent, $Status, $Message
    Add-Content -LiteralPath $MainLog -Value $line -Encoding UTF8

    $color = switch ($Status) {
        'PASS'    { 'Green' }
        'WARN'    { 'Yellow' }
        'FAIL'    { 'Red' }
        'BLOCKED' { 'Red' }
        'RUNNING' { 'Cyan' }
        default   { 'Gray' }
    }
    Write-Host $line -ForegroundColor $color
    Write-Progress -Activity $BuildName -Status ("{0} {1} - {2}" -f $Step, $StepNames[$Step], $Status) -PercentComplete $script:CurrentPercent
}

function Add-RunWarning([string]$Message) {
    $script:RunWarnings.Add($Message)
}
function Add-RunError([string]$Message) {
    $script:RunErrors.Add($Message)
}

function Save-BuildState {
    param([string]$LastMessage = '')
    $state = [ordered]@{
        schemaVersion = 1
        scriptVersion = $ScriptVersion
        updatedAt = (Get-Date).ToString('o')
        lastRunId = $RunId
        parameterFile = $ParameterFile
        parameterHash = $script:ParameterHash
        skeletonPath = $SkeletonFinalPath
        steps = $script:StepStatus
        lastMessage = $LastMessage
    }
    $state | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $StatePath -Encoding UTF8
}

function Load-PreviousState {
    if (-not (Test-Path -LiteralPath $StatePath)) { return $null }
    try {
        return Get-Content -LiteralPath $StatePath -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch {
        Write-RunLog 'S00' 'STATE' 0 'WARN' ("Existing state file cannot be parsed; starting fresh. {0}" -f $_.Exception.Message)
        Add-RunWarning 'Existing build_state.json could not be parsed.'
        return $null
    }
}

function Set-StepStatus {
    param([string]$Step, [string]$Status, [string]$Message = '')
    $script:StepStatus[$Step] = $Status
    Save-BuildState -LastMessage $Message
}

function Test-PidAlive([int]$Pid) {
    if ($Pid -le 0) { return $false }
    try { return $null -ne (Get-Process -Id $Pid -ErrorAction Stop) } catch { return $false }
}

function Acquire-BuildLock {
    if (Test-Path -LiteralPath $LockPath) {
        $oldText = Get-Content -LiteralPath $LockPath -Raw -ErrorAction SilentlyContinue
        $oldPid = 0
        if ($oldText -match 'pid=(\d+)') { $oldPid = [int]$Matches[1] }
        if ($oldPid -gt 0 -and (Test-PidAlive $oldPid)) {
            throw "BLOCKED: another build is running (PID=$oldPid). Lock: $LockPath"
        }
        Write-RunLog 'S00' 'LOCK' 1 'WARN' 'Stale build lock found; removing it.'
        Remove-Item -LiteralPath $LockPath -Force -ErrorAction SilentlyContinue
    }
    @("pid=$PID", "runId=$RunId", "started=$((Get-Date).ToString('o'))") | Set-Content -LiteralPath $LockPath -Encoding ASCII
    $script:LockOwned = $true
}

function Release-BuildLock {
    if ($script:LockOwned -and (Test-Path -LiteralPath $LockPath)) {
        Remove-Item -LiteralPath $LockPath -Force -ErrorAction SilentlyContinue
    }
    $script:LockOwned = $false
}

function Find-FirstExistingPath([string[]]$Candidates) {
    foreach ($c in $Candidates) {
        if (-not [string]::IsNullOrWhiteSpace($c) -and (Test-Path -LiteralPath $c)) {
            return (Resolve-Path -LiteralPath $c).Path
        }
    }
    return $null
}

function Find-SolidWorksFile([string]$FileName) {
    $roots = @()
    if ($env:ProgramFiles) { $roots += (Join-Path $env:ProgramFiles 'SOLIDWORKS Corp') }
    if (${env:ProgramFiles(x86)}) { $roots += (Join-Path ${env:ProgramFiles(x86)} 'SOLIDWORKS Corp') }
    foreach ($root in $roots | Select-Object -Unique) {
        if (Test-Path -LiteralPath $root) {
            $found = Get-ChildItem -LiteralPath $root -Filter $FileName -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($found) { return $found.FullName }
        }
    }
    return $null
}

function Get-FileSha256([string]$Path) {
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Resolve-Q347FParameters {
    param([string]$Path)

    $values = [ordered]@{}
    $raw = [ordered]@{}
    $pending = New-Object System.Collections.Generic.List[object]

    $lineNo = 0
    foreach ($line in Get-Content -LiteralPath $Path -Encoding UTF8) {
        $lineNo++
        $t = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($t) -or $t.StartsWith('#') -or $t.StartsWith('//')) { continue }
        if ($t -notmatch '^"([^"]+)"\s*=\s*(.+)$') {
            throw "Unsupported parameter syntax at line ${lineNo}: $t"
        }
        $pending.Add([pscustomobject]@{ Name = $Matches[1]; Expr = $Matches[2].Trim(); Line = $lineNo; Raw = $t })
        $raw[$Matches[1]] = $t
    }

    $maxPass = [Math]::Max(10, $pending.Count * 2)
    for ($pass = 0; $pass -lt $maxPass -and $pending.Count -gt 0; $pass++) {
        $resolvedThisPass = 0
        for ($i = $pending.Count - 1; $i -ge 0; $i--) {
            $item = $pending[$i]
            $expr = [string]$item.Expr
            $refs = [regex]::Matches($expr, '"([^"]+)"')
            $canResolve = $true
            foreach ($m in $refs) {
                $refName = $m.Groups[1].Value
                if (-not $values.Contains($refName)) { $canResolve = $false; break }
                $replacement = ([double]$values[$refName]).ToString('R', [Globalization.CultureInfo]::InvariantCulture)
                $expr = $expr.Replace($m.Value, $replacement)
            }
            if (-not $canResolve) { continue }

            $expr = $expr -replace '(?i)mm\b', ''
            $expr = $expr -replace '(?i)deg\b', ''
            $expr = $expr.Trim()
            if ($expr -notmatch '^[0-9eE\.\+\-\*/\(\)\s]+$') {
                throw "Unsafe/unsupported expression for $($item.Name) at line $($item.Line): $expr"
            }
            try {
                $dt = New-Object System.Data.DataTable
                $dt.Locale = [Globalization.CultureInfo]::InvariantCulture
                $v = $dt.Compute($expr, '')
                $values[$item.Name] = [double]::Parse([string]$v, [Globalization.CultureInfo]::InvariantCulture)
                $pending.RemoveAt($i)
                $resolvedThisPass++
            } catch {
                throw "Failed to evaluate $($item.Name) at line $($item.Line): $expr. $($_.Exception.Message)"
            }
        }
        if ($resolvedThisPass -eq 0 -and $pending.Count -gt 0) {
            $left = ($pending | ForEach-Object { $_.Name }) -join ', '
            throw "Unresolved parameter references: $left"
        }
    }
    if ($pending.Count -gt 0) {
        throw "Parameter resolution did not converge: $((($pending | ForEach-Object { $_.Name }) -join ', '))"
    }
    return [pscustomobject]@{ Values = $values; Raw = $raw }
}

function Assert-Near {
    param([string]$Name, [double]$Actual, [double]$Expected, [double]$Tolerance = 0.001)
    if ([Math]::Abs($Actual - $Expected) -gt $Tolerance) {
        throw "Parameter check failed: $Name actual=$Actual expected=$Expected tol=$Tolerance"
    }
}

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function Get-Param([string]$Name) {
    if (-not $script:Params.Contains($Name)) { throw "Required parameter missing: $Name" }
    return [double]$script:Params[$Name]
}

function Convert-StationName([string]$Axis, [double]$Value) {
    if ([Math]::Abs($Value) -lt 0.0000001) { return "PLN_${Axis}_000_000" }
    $prefix = if ($Value -lt 0) { 'M' } else { 'P' }
    $abs = [Math]::Abs($Value)
    $s = $abs.ToString('000.000', [Globalization.CultureInfo]::InvariantCulture).Replace('.', '_')
    return "PLN_${Axis}_${prefix}${s}"
}
