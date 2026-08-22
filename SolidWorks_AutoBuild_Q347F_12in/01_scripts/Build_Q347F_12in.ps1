[CmdletBinding()]
param(
    [switch]$Resume,
    [string]$ParameterFile,
    [string]$OutputRoot,
    [bool]$KeepSolidWorksOpen = $true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptVersion = '0.2.0-S00-S04-ball'
$BuildName = 'Q347F 12in Class150 AUTO BUILD'
$RequiredSwMajorRevision = 33   # SOLIDWORKS 2025
$RunId = Get-Date -Format 'yyyyMMdd_HHmmss'
$RunStarted = Get-Date

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AutoRoot = Split-Path -Parent $ScriptDir
$RepoRoot = Split-Path -Parent $AutoRoot

if ([string]::IsNullOrWhiteSpace($ParameterFile)) {
    $ParameterFile = Join-Path $RepoRoot 'Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt'
}
if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
    $OutputRoot = Join-Path $AutoRoot '02_output'
}

$BackupRoot = Join-Path $AutoRoot '03_backup'
$LogsRoot = Join-Path $AutoRoot '04_logs'
$RunLogDir = Join-Path $LogsRoot ("run_{0}" -f $RunId)
$RunBackupDir = Join-Path $BackupRoot ("run_{0}" -f $RunId)
$StatePath = Join-Path $OutputRoot 'build_state.json'
$LockPath = Join-Path $AutoRoot '.build.lock'
$MainLog = Join-Path $RunLogDir 'build.log'
$SummaryPath = Join-Path $RunLogDir 'summary.json'
$ParameterSnapshotPath = Join-Path $RunLogDir 'parameters_snapshot.txt'
$SkeletonFinalPath = Join-Path $OutputRoot '00_SKELETON.SLDPRT'
$SkeletonStagingPath = Join-Path $RunBackupDir '00_SKELETON_staging.SLDPRT'
$BallFinalPath = Join-Path $OutputRoot '01_BALL.SLDPRT'
$BallStagingPath = Join-Path $RunBackupDir '01_BALL_staging.SLDPRT'

$StepNames = [ordered]@{
    S00 = 'ENVIRONMENT'
    S01 = 'PARAMETERS'
    S02 = 'SOLIDWORKS'
    S03 = 'SKELETON'
    S04 = 'BALL'
    S05 = 'SEATS'
    S06 = 'BODY'
    S07 = 'BODY_COVER'
    S08 = 'Z_PARTS'
    S09 = 'ADAPTER'
    S10 = 'ASSEMBLY'
    S11 = 'VALIDATION'
    S12 = 'REPORT'
}

$StepRanges = @{
    S00 = @(0, 5)
    S01 = @(5, 10)
    S02 = @(10, 15)
    S03 = @(15, 25)
    S04 = @(25, 34)
    S05 = @(34, 43)
    S06 = @(43, 57)
    S07 = @(57, 67)
    S08 = @(67, 78)
    S09 = @(78, 84)
    S10 = @(84, 92)
    S11 = @(92, 98)
    S12 = @(98, 100)
}

$script:StepStatus = [ordered]@{}
foreach ($k in $StepNames.Keys) { $script:StepStatus[$k] = 'WAITING' }
$script:CurrentStep = 'S00'
$script:CurrentObject = 'ENV'
$script:CurrentPercent = 0
$script:ParameterHash = $null
$script:Params = @{}
$script:SwApp = $null
$script:SwConnectionMode = $null
$script:SwRevision = $null
$script:SwPid = $null
$script:InteropSldworks = $null
$script:InteropSwconst = $null
$script:SldworksExe = $null
$script:LockOwned = $false
$script:RunWarnings = New-Object System.Collections.Generic.List[string]
$script:RunErrors = New-Object System.Collections.Generic.List[string]
$script:PreviousState = $null
$script:PartTemplate = $null

New-Item -ItemType Directory -Force -Path $OutputRoot, $BackupRoot, $LogsRoot, $RunLogDir, $RunBackupDir | Out-Null

# Shared runtime helpers and embedded SOLIDWORKS COM API layer.
. (Join-Path $ScriptDir 'lib\Q347F_Common.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_Config.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_SwSessionApi.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_SwEquationApi.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_SwGeometryApi.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_SwValidationApi.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_SwBallApi.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_Stages_S00_S02.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_Stage_S03.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_Stage_S04.ps1')

function Write-FinalSummary {
    param([string]$OverallStatus, [string]$Message)
    $elapsed = (Get-Date) - $RunStarted
    $summary = [ordered]@{
        runId = $RunId
        scriptVersion = $ScriptVersion
        overallStatus = $OverallStatus
        message = $Message
        startedAt = $RunStarted.ToString('o')
        finishedAt = (Get-Date).ToString('o')
        elapsed = $elapsed.ToString()
        parameterFile = $ParameterFile
        parameterHash = $script:ParameterHash
        solidWorks = [ordered]@{
            connection = $script:SwConnectionMode
            revision = $script:SwRevision
            pid = $script:SwPid
            exe = $script:SldworksExe
        }
        output = [ordered]@{
            skeleton = $SkeletonFinalPath
            ball = $BallFinalPath
            runLogDir = $RunLogDir
            skeletonStaging = $SkeletonStagingPath
            ballStaging = $BallStagingPath
        }
        steps = $script:StepStatus
        warnings = @($script:RunWarnings)
        errors = @($script:RunErrors)
        currentMilestone = 'S00-S04 implemented. S04 generates editable 01_BALL.SLDPRT from current CAD-draft candidate dimensions; manufacturing freeze is a separate engineering gate.'
    }
    $summary | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $SummaryPath -Encoding UTF8

    Write-Host ''
    Write-Host '============================================================' -ForegroundColor DarkGray
    Write-Host $BuildName -ForegroundColor White
    Write-Host ("Run ID : {0}" -f $RunId)
    Write-Host ("Status : {0}" -f $OverallStatus) -ForegroundColor $(if ($OverallStatus -eq 'PASS') { 'Green' } else { 'Red' })
    Write-Host ("S00    : {0}" -f $script:StepStatus['S00'])
    Write-Host ("S01    : {0}" -f $script:StepStatus['S01'])
    Write-Host ("S02    : {0}" -f $script:StepStatus['S02'])
    Write-Host ("S03    : {0}" -f $script:StepStatus['S03'])
    Write-Host ("S04    : {0}" -f $script:StepStatus['S04'])
    Write-Host 'S05-S12: WAITING (not implemented yet)'
    Write-Host ("Skeleton: {0}" -f $SkeletonFinalPath)
    Write-Host ("Ball    : {0}" -f $BallFinalPath)
    Write-Host ("Logs    : {0}" -f $RunLogDir)
    Write-Host '============================================================' -ForegroundColor DarkGray
}

$exitCode = 0
try {
    "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] RunId=$RunId ScriptVersion=$ScriptVersion Resume=$Resume" | Set-Content -LiteralPath $MainLog -Encoding UTF8
    Initialize-ResumeState

    # S00 always reruns because machine/process state is volatile.
    $script:StepStatus['S00'] = 'WAITING'
    Invoke-S00

    # S01 always reruns so parameter hash and geometry guards are current.
    $script:StepStatus['S01'] = 'WAITING'
    Invoke-S01

    # S02 always reruns because COM session is process-local.
    $script:StepStatus['S02'] = 'WAITING'
    Invoke-S02

    # S04 has its own embedded C# geometry layer. Compile only after S00 loaded the SOLIDWORKS interop assemblies.
    Add-EmbeddedSwBallApiType
    Write-RunLog 'S02' 'CSHARP_S04' 15 'PASS' 'S04 BALL embedded C# API compiled and ready.'

    $resumeHashMatches = $false
    if ($Resume -and $script:PreviousState -and $script:PreviousState.parameterHash) {
        $resumeHashMatches = ([string]$script:PreviousState.parameterHash -eq [string]$script:ParameterHash)
    }

    if ($Resume -and $resumeHashMatches -and $script:StepStatus['S03'] -eq 'PASS' -and (Test-Path -LiteralPath $SkeletonFinalPath)) {
        Write-RunLog 'S03' 'RESUME' 25 'SKIP' 'Previous S03 is PASS, parameter hash is unchanged, and 00_SKELETON.SLDPRT exists. S03 skipped.'
    } else {
        Invoke-S03
    }

    if ($Resume -and $resumeHashMatches -and $script:StepStatus['S04'] -eq 'PASS' -and (Test-Path -LiteralPath $BallFinalPath)) {
        Write-RunLog 'S04' 'RESUME' 34 'SKIP' 'Previous S04 is PASS, parameter hash is unchanged, and 01_BALL.SLDPRT exists. S04 skipped.'
    } else {
        Invoke-S04
    }

    Write-Progress -Activity $BuildName -Completed
    Write-FinalSummary 'PASS' 'S00-S04 completed. Skeleton and complete editable BALL milestone generated.'
    $exitCode = 0
}
catch {
    $msg = $_.Exception.Message
    $step = $script:CurrentStep
    if ([string]::IsNullOrWhiteSpace($step)) { $step = 'S00' }
    $status = if ($msg.StartsWith('BLOCKED:', [StringComparison]::OrdinalIgnoreCase)) { 'BLOCKED' } else { 'FAIL' }
    $script:StepStatus[$step] = $status
    Add-RunError $msg
    try { Save-BuildState -LastMessage $msg } catch { }
    try { Write-RunLog $step $script:CurrentObject $script:CurrentPercent $status $msg } catch { Write-Host $msg -ForegroundColor Red }
    try { Write-FinalSummary $status $msg } catch { }
    Write-Progress -Activity $BuildName -Completed
    $exitCode = 2
}
finally {
    Release-BuildLock
}

exit $exitCode