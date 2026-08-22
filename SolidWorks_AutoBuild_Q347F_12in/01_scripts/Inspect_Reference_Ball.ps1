[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$PartPath,
    [string]$OutputDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AutoRoot = Split-Path -Parent $ScriptDir
$RepoRoot = Split-Path -Parent $AutoRoot
$OutputRoot = Join-Path $AutoRoot '02_output'
$BuildName = 'Q347F REFERENCE BALL INSPECTOR'
$StepNames = @{ REF='REFERENCE_INSPECT' }
$MainLog = Join-Path $AutoRoot '04_logs\reference_ball_inspector.log'

. (Join-Path $ScriptDir 'lib\Q347F_Common.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_Config.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_SwSessionApi.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_SwReferenceInspectorApi.ps1')

$PartPath = [Environment]::ExpandEnvironmentVariables($PartPath)
if (-not (Test-Path -LiteralPath $PartPath)) {
    throw "Reference part not found: $PartPath"
}
$PartPath = (Resolve-Path -LiteralPath $PartPath).Path

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path $AutoRoot ('04_logs\reference_ball_{0}' -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
}
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$script:SldworksExe = Find-SolidWorksFile 'SLDWORKS.exe'
if (-not $script:SldworksExe) { throw 'SLDWORKS.exe not found from build_config.json or auto discovery.' }
$apiRedist = Join-Path (Split-Path -Parent $script:SldworksExe) 'api\redist'
$script:InteropSldworks = Find-FirstExistingPath @((Join-Path $apiRedist 'SolidWorks.Interop.sldworks.dll'))
if (-not $script:InteropSldworks) { $script:InteropSldworks = Find-SolidWorksFile 'SolidWorks.Interop.sldworks.dll' }
$script:InteropSwconst = Find-FirstExistingPath @((Join-Path $apiRedist 'SolidWorks.Interop.swconst.dll'))
if (-not $script:InteropSwconst) { $script:InteropSwconst = Find-SolidWorksFile 'SolidWorks.Interop.swconst.dll' }
if (-not $script:InteropSldworks -or -not $script:InteropSwconst) { throw 'SOLIDWORKS interop DLLs not found.' }

[void](Initialize-SolidWorksInteropAssemblies -SldworksPath $script:InteropSldworks -SwconstPath $script:InteropSwconst)
Add-EmbeddedSwSessionApiType
Add-EmbeddedSwReferenceInspectorApiType

Write-Host '[REF][RUNNING] Connecting to SOLIDWORKS 2025...' -ForegroundColor Cyan
$session = [Q347F.SwSessionApi]::ConnectOrStart()
Write-Host ("[REF][PASS] Connection={0} PID={1} Revision={2}" -f $session.Mode, $session.ProcessId, $session.Revision) -ForegroundColor Green
Write-Host ("[REF][RUNNING] Reading: {0}" -f $PartPath) -ForegroundColor Cyan

$report = [Q347F.SwReferenceInspectorApi]::Inspect($session, $PartPath)

$jsonPath = Join-Path $OutputDir '20in_ball_reference_report.json'
$csvPath = Join-Path $OutputDir '20in_ball_feature_dimensions.csv'
$treePath = Join-Path $OutputDir '20in_ball_feature_tree.txt'

$report | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

$rows = foreach ($f in $report.Features) {
    if ($f.Dimensions.Count -eq 0) {
        [pscustomobject]@{
            Order=$f.Order; Level=$f.Level; Parent=$f.ParentName; Feature=$f.Name; Type=$f.TypeName;
            Dimension=''; FullName=''; SystemValue=''; ApproxMm=''; Suppressed=$f.Suppressed
        }
    } else {
        foreach ($d in $f.Dimensions) {
            [pscustomobject]@{
                Order=$f.Order; Level=$f.Level; Parent=$f.ParentName; Feature=$f.Name; Type=$f.TypeName;
                Dimension=$d.Name; FullName=$d.FullName; SystemValue=$d.SystemValue; ApproxMm=$d.ApproxMm; Suppressed=$f.Suppressed
            }
        }
    }
}
$rows | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8

$treeLines = foreach ($f in ($report.Features | Sort-Object Order)) {
    $indent = '  ' * [int]$f.Level
    $dims = if ($f.Dimensions.Count -gt 0) {
        ' | ' + (($f.Dimensions | ForEach-Object { '{0}={1:N3}mm' -f $_.Name, $_.ApproxMm }) -join '; ')
    } else { '' }
    '{0}{1:000}. {2} [{3}]{4}' -f $indent, $f.Order, $f.Name, $f.TypeName, $dims
}
$treeLines | Set-Content -LiteralPath $treePath -Encoding UTF8

Write-Host ''
Write-Host '============================================================' -ForegroundColor DarkGray
Write-Host '20in BALL REFERENCE INSPECTION PASS' -ForegroundColor Green
Write-Host ("Title        : {0}" -f $report.Title)
Write-Host ("Configuration: {0}" -f $report.ActiveConfiguration)
Write-Host ("Features     : {0}" -f $report.FeatureCount)
Write-Host ("Solid bodies : {0}" -f $report.SolidBodyCount)
if ($report.BoundingBoxMm -and $report.BoundingBoxMm.Length -ge 6) {
    Write-Host ("BBox mm      : X {0:N3}..{1:N3}; Y {2:N3}..{3:N3}; Z {4:N3}..{5:N3}" -f $report.BoundingBoxMm[0],$report.BoundingBoxMm[3],$report.BoundingBoxMm[1],$report.BoundingBoxMm[4],$report.BoundingBoxMm[2],$report.BoundingBoxMm[5])
}
Write-Host ("JSON         : {0}" -f $jsonPath)
Write-Host ("CSV          : {0}" -f $csvPath)
Write-Host ("Feature tree : {0}" -f $treePath)
Write-Host '============================================================' -ForegroundColor DarkGray
