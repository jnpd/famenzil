[CmdletBinding()]
param(
    [string]$PartPath,
    [string]$OutputDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AutoRoot = Split-Path -Parent $ScriptDir
$LogsRoot = Join-Path $AutoRoot '04_logs'

. (Join-Path $ScriptDir 'lib\Q347F_Common.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_Config.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_InteropLoader.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_SwSessionApi.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_SwBallReferenceDeepInspectorApi.ps1')

function Find-Latest20inReferenceBall {
    $dirs = @(Get-ChildItem -LiteralPath $LogsRoot -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like 'reference_assembly_*' } |
        Sort-Object LastWriteTime -Descending)

    foreach ($dir in $dirs) {
        $files = @(Get-ChildItem -LiteralPath $dir.FullName -Recurse -File -Filter '*.SLDPRT' -ErrorAction SilentlyContinue)
        $exact = $files | Where-Object { $_.Name -like '20Q347F-300LB-03*' -and ($_.Name -match '球体' -or $_.Name -match '#U7403#U4f53') } | Select-Object -First 1
        if ($exact) { return $exact.FullName }
        $fallback = $files | Where-Object { $_.Name -like '20Q347F-300LB-03*' } | Select-Object -First 1
        if ($fallback) { return $fallback.FullName }
    }
    return $null
}

if ([string]::IsNullOrWhiteSpace($PartPath)) {
    $PartPath = Find-Latest20inReferenceBall
    if (-not $PartPath) {
        throw '20in reference BALL was not found automatically under 04_logs\reference_assembly_*. Pass -PartPath explicitly.'
    }
}

$PartPath = [Environment]::ExpandEnvironmentVariables($PartPath)
if (-not (Test-Path -LiteralPath $PartPath)) { throw "Reference BALL not found: $PartPath" }
$PartPath = (Resolve-Path -LiteralPath $PartPath).Path

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path $LogsRoot ('reference_ball_deep_{0}' -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
}
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

Write-Host '============================================================' -ForegroundColor DarkGray
Write-Host 'Q347F BALL REFERENCE DEEP INSPECTOR' -ForegroundColor Cyan
Write-Host 'TARGET    : 12in / NPS12 / DN300 / Class150 (model to build)' -ForegroundColor Green
Write-Host 'REFERENCE : 20in / 300LB BALL (READ ONLY; topology reference only)' -ForegroundColor Yellow
Write-Host '20in dimensions are NOT written into the 12in parameter source.' -ForegroundColor Yellow
Write-Host '============================================================' -ForegroundColor DarkGray
Write-Host ("[REF20][RUNNING] Source: {0}" -f $PartPath) -ForegroundColor Cyan

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
Add-EmbeddedSwBallReferenceDeepInspectorApiType

$session = [Q347F.SwSessionApi]::ConnectOrStart()
Write-Host ("[REF20][PASS] SOLIDWORKS connection={0}; PID={1}; Revision={2}" -f $session.Mode, $session.ProcessId, $session.Revision) -ForegroundColor Green

$report = [Q347F.SwBallReferenceDeepInspectorApi]::Inspect($session.App, $PartPath)

$jsonPath = Join-Path $OutputDir '20in_ball_deep_report.json'
$sketchPath = Join-Path $OutputDir '20in_ball_sketches.csv'
$segmentPath = Join-Path $OutputDir '20in_ball_sketch_segments.csv'
$pointPath = Join-Path $OutputDir '20in_ball_sketch_points.csv'
$defPath = Join-Path $OutputDir '20in_ball_feature_definitions.csv'
$criticalPath = Join-Path $OutputDir '20in_ball_critical_sketch_summary.txt'

$report | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $jsonPath -Encoding UTF8
$report.Sketches | Select-Object SketchName,SegmentCount,PointCount,XMinMm,XMaxMm,YMinMm,YMaxMm,ZMinMm,ZMaxMm,ModelToSketchTransform |
    Export-Csv -LiteralPath $sketchPath -NoTypeInformation -Encoding UTF8
$report.Segments | Select-Object SketchName,SegmentIndex,Kind,Construction,LengthMm,StartXmm,StartYmm,StartZmm,EndXmm,EndYmm,EndZmm,CenterXmm,CenterYmm,CenterZmm,RadiusMm,IsCircle,RotationDir |
    Export-Csv -LiteralPath $segmentPath -NoTypeInformation -Encoding UTF8
$report.Points | Select-Object SketchName,PointIndex,Xmm,Ymm,Zmm |
    Export-Csv -LiteralPath $pointPath -NoTypeInformation -Encoding UTF8
$report.FeatureDefinitions | Select-Object Order,FeatureName,TypeName2,UnderlyingType,DefinitionKind,Summary |
    Export-Csv -LiteralPath $defPath -NoTypeInformation -Encoding UTF8

$criticalNames = @('草图1','草图2','草图3','草图4','草图10','草图14','草图15')
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('TARGET=12in NPS12 DN300 Class150; REFERENCE=20in 300LB READ-ONLY')
$lines.Add('This file describes the 20in reference topology only. Do not copy dimensions directly into the 12in model.')
$lines.Add('')
foreach ($name in $criticalNames) {
    $s = $report.Sketches | Where-Object { $_.SketchName -eq $name } | Select-Object -First 1
    if (-not $s) { continue }
    $lines.Add(("[{0}] segments={1}; points={2}; bbox=({3:N3},{4:N3})..({5:N3},{6:N3}) mm" -f $name,$s.SegmentCount,$s.PointCount,$s.XMinMm,$s.YMinMm,$s.XMaxMm,$s.YMaxMm))
    foreach ($seg in @($report.Segments | Where-Object { $_.SketchName -eq $name })) {
        if ($seg.Kind -eq 'LINE') {
            $lines.Add(("  SEG#{0} LINE C={1} ({2:N3},{3:N3},{4:N3})->({5:N3},{6:N3},{7:N3}) L={8:N3}" -f $seg.SegmentIndex,$seg.Construction,$seg.StartXmm,$seg.StartYmm,$seg.StartZmm,$seg.EndXmm,$seg.EndYmm,$seg.EndZmm,$seg.LengthMm))
        } elseif ($seg.Kind -eq 'ARC' -or $seg.Kind -eq 'CIRCLE') {
            $lines.Add(("  SEG#{0} {1} C={2} center=({3:N3},{4:N3},{5:N3}) R={6:N3} start=({7:N3},{8:N3}) end=({9:N3},{10:N3})" -f $seg.SegmentIndex,$seg.Kind,$seg.Construction,$seg.CenterXmm,$seg.CenterYmm,$seg.CenterZmm,$seg.RadiusMm,$seg.StartXmm,$seg.StartYmm,$seg.EndXmm,$seg.EndYmm))
        } else {
            $lines.Add(("  SEG#{0} {1}" -f $seg.SegmentIndex,$seg.Kind))
        }
    }
    foreach ($pt in @($report.Points | Where-Object { $_.SketchName -eq $name })) {
        $lines.Add(("  PT#{0} ({1:N3},{2:N3},{3:N3})" -f $pt.PointIndex,$pt.Xmm,$pt.Ymm,$pt.Zmm))
    }
    $lines.Add('')
}
$lines | Set-Content -LiteralPath $criticalPath -Encoding UTF8

Write-Host ''
Write-Host '============================================================' -ForegroundColor DarkGray
Write-Host '20in REFERENCE BALL DEEP INSPECTION PASS' -ForegroundColor Green
Write-Host ("Title       : {0}" -f $report.Title)
Write-Host ("Config      : {0}" -f $report.Configuration)
Write-Host ("Sketches    : {0}" -f $report.Sketches.Count)
Write-Host ("Segments    : {0}" -f $report.Segments.Count)
Write-Host ("Points      : {0}" -f $report.Points.Count)
Write-Host ("Output      : {0}" -f $OutputDir)
Write-Host 'Next gate   : use this reference report to correct the 12in S04 BALL topology; do NOT copy 20in dimensions directly.' -ForegroundColor Yellow
Write-Host '============================================================' -ForegroundColor DarkGray
