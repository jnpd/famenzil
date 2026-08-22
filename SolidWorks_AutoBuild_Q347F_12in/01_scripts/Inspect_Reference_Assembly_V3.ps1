[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RootAssemblyPath,
    [Parameter(Mandatory)][string]$OutputDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AutoRoot = Split-Path -Parent $ScriptDir

. (Join-Path $ScriptDir 'lib\Q347F_Common.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_Config.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_SwSessionApi.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_SwReferenceInspectorApi.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_SwAssemblyInspectorApi.ps1')

$RootAssemblyPath = (Resolve-Path -LiteralPath $RootAssemblyPath).Path
$PackRoot = Split-Path -Parent $RootAssemblyPath
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$allAssemblies = @(Get-ChildItem -LiteralPath $PackRoot -Recurse -File -Filter '*.SLDASM' | Sort-Object FullName)
$AssemblyFiles = @(
    $allAssemblies | Where-Object {
        $_.FullName -ieq $RootAssemblyPath -or $_.BaseName -match '^20Q347F-300LB-\d'
    } | Sort-Object @{Expression={ if ($_.FullName -ieq $RootAssemblyPath) { 0 } else { 1 } }}, FullName
)
$PartFiles = @(Get-ChildItem -LiteralPath $PackRoot -Recurse -File -Filter '*.SLDPRT' | Sort-Object FullName)

Write-Host ''
Write-Host '============================================================' -ForegroundColor DarkGray
Write-Host 'Q347F 20in REVERSE INSPECTOR V3 - STRONG TYPED INTEROP' -ForegroundColor Cyan
Write-Host ("Root assembly : {0}" -f $RootAssemblyPath)
Write-Host ("SLDASM files  : {0}" -f $AssemblyFiles.Count)
Write-Host ("SLDPRT files  : {0}" -f $PartFiles.Count)
Write-Host ("Output        : {0}" -f $OutputDir)
Write-Host '============================================================' -ForegroundColor DarkGray

$script:SldworksExe = Find-SolidWorksFile 'SLDWORKS.exe'
if (-not $script:SldworksExe) { throw 'SLDWORKS.exe not found.' }
$apiRedist = Join-Path (Split-Path -Parent $script:SldworksExe) 'api\redist'
$script:InteropSldworks = Find-FirstExistingPath @((Join-Path $apiRedist 'SolidWorks.Interop.sldworks.dll'))
if (-not $script:InteropSldworks) { $script:InteropSldworks = Find-SolidWorksFile 'SolidWorks.Interop.sldworks.dll' }
$script:InteropSwconst = Find-FirstExistingPath @((Join-Path $apiRedist 'SolidWorks.Interop.swconst.dll'))
if (-not $script:InteropSwconst) { $script:InteropSwconst = Find-SolidWorksFile 'SolidWorks.Interop.swconst.dll' }
if (-not $script:InteropSldworks -or -not $script:InteropSwconst) { throw 'SOLIDWORKS interop DLLs not found.' }

[void](Initialize-SolidWorksInteropAssemblies -SldworksPath $script:InteropSldworks -SwconstPath $script:InteropSwconst)
Write-Host '[A01-COMPILE][RUNNING] Compiling strong-typed APIs...' -ForegroundColor Cyan
Add-EmbeddedSwSessionApiType
Add-EmbeddedSwReferenceInspectorApiType
Add-EmbeddedSwAssemblyInspectorApiType
Write-Host '[A01-COMPILE][PASS] Session + part inspector + assembly inspector compiled.' -ForegroundColor Green

Write-Host '[A01][RUNNING] Connecting to SOLIDWORKS 2025...' -ForegroundColor Cyan
$session = [Q347F.SwSessionApi]::ConnectOrStart()
$app = $session.App
$revision = [string]$session.Revision
Write-Host ("[A01][PASS] Connection={0} PID={1} Revision={2}" -f $session.Mode,$session.ProcessId,$revision) -ForegroundColor Green

# Fail-fast probe. Do not scan 42 files until the common open/read path is proven.
$probe = @($PartFiles | Where-Object { $_.BaseName -eq '20Q347F-300LB-03 球体' } | Select-Object -First 1)
if ($probe.Count -eq 0) { throw 'Probe part 20Q347F-300LB-03 球体.SLDPRT was not found in Pack and Go.' }
Write-Host ("[A01-PROBE][RUNNING] {0}" -f $probe[0].Name) -ForegroundColor Cyan
try {
    $probeReport = [Q347F.SwReferenceInspectorApi]::Inspect($app, $revision, $probe[0].FullName)
    Write-Host ("[A01-PROBE][PASS] Title={0}; Features={1}; SolidBodies={2}" -f $probeReport.Title,$probeReport.FeatureCount,$probeReport.SolidBodyCount) -ForegroundColor Green
}
catch {
    Write-Host ("[A01-PROBE][FAIL] {0}" -f $_.Exception.Message) -ForegroundColor Red
    throw 'Common SOLIDWORKS reference inspection path failed on the BALL probe. Full 42-file scan was intentionally NOT started.'
}

$inspectionErrors = New-Object System.Collections.Generic.List[object]
$assemblyReports = New-Object System.Collections.Generic.List[object]
$partReports = New-Object System.Collections.Generic.List[object]

$ai = 0
foreach ($asm in $AssemblyFiles) {
    $ai++
    Write-Host ("[A02][RUNNING] Assembly {0}/{1}: {2}" -f $ai,$AssemblyFiles.Count,$asm.Name) -ForegroundColor Cyan
    try {
        $r = [Q347F.SwAssemblyInspectorApi]::Inspect($app, $revision, $asm.FullName)
        $assemblyReports.Add($r)
        Write-Host ("[A02][PASS] Components={0}; Mates={1}; MissingRefs={2}; Lightweight={3}" -f $r.ComponentCount,$r.MateCount,$r.MissingReferenceCount,$r.LightweightComponentCount) -ForegroundColor Green
    }
    catch {
        $inspectionErrors.Add([pscustomobject]@{ Stage='ASSEMBLY'; File=$asm.FullName; Error=$_.Exception.Message })
        Write-Host ("[A02][WARN] {0}: {1}" -f $asm.Name,$_.Exception.Message) -ForegroundColor Yellow
    }
}

$pi = 0
foreach ($part in $PartFiles) {
    $pi++
    Write-Host ("[A03][RUNNING] Part {0}/{1}: {2}" -f $pi,$PartFiles.Count,$part.Name) -ForegroundColor Cyan
    try {
        $p = [Q347F.SwReferenceInspectorApi]::Inspect($app, $revision, $part.FullName)
        $partReports.Add($p)
        Write-Host ("[A03][PASS] Features={0}; SolidBodies={1}" -f $p.FeatureCount,$p.SolidBodyCount) -ForegroundColor Green
    }
    catch {
        $inspectionErrors.Add([pscustomobject]@{ Stage='PART'; File=$part.FullName; Error=$_.Exception.Message })
        Write-Host ("[A03][WARN] {0}: {1}" -f $part.Name,$_.Exception.Message) -ForegroundColor Yellow
    }
}

$asmInventory = foreach ($r in $assemblyReports) {
    [pscustomobject]@{ Assembly=$r.Title; Path=$r.Path; Configuration=$r.ActiveConfiguration; Components=$r.ComponentCount; Mates=$r.MateCount; MissingReferences=$r.MissingReferenceCount; LightweightComponents=$r.LightweightComponentCount; OpenErrors=$r.OpenErrors; OpenWarnings=$r.OpenWarnings }
}
$asmInventory | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_assembly_inventory.csv') -NoTypeInformation -Encoding UTF8

$componentRows = foreach ($r in $assemblyReports) {
    foreach ($c in $r.Components) {
        [pscustomobject]@{ Assembly=$r.Title; AssemblyPath=$r.Path; Order=$c.Order; Level=$c.Level; Parent=$c.ParentName; Component=$c.Name; ComponentPath=$c.Path; Configuration=$c.ReferencedConfiguration; DocumentType=$c.DocumentType; SuppressionState=$c.SuppressionState; Hidden=$c.Hidden; Fixed=$c.Fixed; MissingReference=$c.MissingReference; X_mm=$c.TxMm; Y_mm=$c.TyMm; Z_mm=$c.TzMm }
    }
}
$componentRows | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_component_tree.csv') -NoTypeInformation -Encoding UTF8

$transformRows = foreach ($r in $assemblyReports) {
    foreach ($c in $r.Components) {
        $t=@($c.Transform)
        [pscustomobject]@{ Assembly=$r.Title; Component=$c.Name; ComponentPath=$c.Path; R11=$(if($t.Count-gt 0){$t[0]}else{$null}); R12=$(if($t.Count-gt 1){$t[1]}else{$null}); R13=$(if($t.Count-gt 2){$t[2]}else{$null}); R21=$(if($t.Count-gt 3){$t[3]}else{$null}); R22=$(if($t.Count-gt 4){$t[4]}else{$null}); R23=$(if($t.Count-gt 5){$t[5]}else{$null}); R31=$(if($t.Count-gt 6){$t[6]}else{$null}); R32=$(if($t.Count-gt 7){$t[7]}else{$null}); R33=$(if($t.Count-gt 8){$t[8]}else{$null}); X_mm=$c.TxMm; Y_mm=$c.TyMm; Z_mm=$c.TzMm; Scale=$(if($t.Count-gt 12){$t[12]}else{$null}) }
    }
}
$transformRows | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_transforms.csv') -NoTypeInformation -Encoding UTF8

$mateRows = foreach ($r in $assemblyReports) {
    foreach ($m in $r.Mates) {
        [pscustomobject]@{ Assembly=$r.Title; AssemblyPath=$r.Path; Order=$m.Order; Mate=$m.Name; Type=$m.TypeName; Suppressed=$m.Suppressed; Alignment=$m.Alignment; EntityCount=$m.Entities.Count; Components=(@($m.Entities | ForEach-Object { if($_.ComponentName){$_.ComponentName}else{'<assembly/reference>'} }) -join ' <-> '); Dimensions=(@($m.Dimensions | ForEach-Object { '{0}={1:N3}mm' -f $_.Name,$_.ApproxMm }) -join '; ') }
    }
}
$mateRows | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_mates.csv') -NoTypeInformation -Encoding UTF8

$mateEntityRows = foreach ($r in $assemblyReports) {
    foreach ($m in $r.Mates) {
        foreach ($e in $m.Entities) {
            [pscustomobject]@{ Assembly=$r.Title; Mate=$m.Name; MateType=$m.TypeName; EntityIndex=$e.Index; Component=$e.ComponentName; ComponentPath=$e.ComponentPath; ReferenceType=$e.ReferenceType; EntityParams=(@($e.EntityParams)-join ';') }
        }
    }
}
$mateEntityRows | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_mate_entities.csv') -NoTypeInformation -Encoding UTF8

$partInventory = foreach ($p in $partReports) {
    $b=@($p.BoundingBoxMm)
    [pscustomobject]@{ Part=$p.Title; Path=$p.Path; Configuration=$p.ActiveConfiguration; Features=$p.FeatureCount; SolidBodies=$p.SolidBodyCount; XMin_mm=$(if($b.Count-ge 6){$b[0]}else{$null}); YMin_mm=$(if($b.Count-ge 6){$b[1]}else{$null}); ZMin_mm=$(if($b.Count-ge 6){$b[2]}else{$null}); XMax_mm=$(if($b.Count-ge 6){$b[3]}else{$null}); YMax_mm=$(if($b.Count-ge 6){$b[4]}else{$null}); ZMax_mm=$(if($b.Count-ge 6){$b[5]}else{$null}); Equations=(@($p.Equations)-join ' | '); MaterialPropertyValues=(@($p.MaterialPropertyValues)-join ';') }
}
$partInventory | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_part_inventory.csv') -NoTypeInformation -Encoding UTF8

$featureRows = foreach ($p in $partReports) {
    foreach ($f in $p.Features) {
        if ($f.Dimensions.Count -eq 0) {
            [pscustomobject]@{ Part=$p.Title; PartPath=$p.Path; Order=$f.Order; Level=$f.Level; Parent=$f.ParentName; Feature=$f.Name; Type=$f.TypeName; Suppressed=$f.Suppressed; Dimension=''; FullName=''; SystemValue=''; ApproxMm='' }
        } else {
            foreach ($d in $f.Dimensions) {
                [pscustomobject]@{ Part=$p.Title; PartPath=$p.Path; Order=$f.Order; Level=$f.Level; Parent=$f.ParentName; Feature=$f.Name; Type=$f.TypeName; Suppressed=$f.Suppressed; Dimension=$d.Name; FullName=$d.FullName; SystemValue=$d.SystemValue; ApproxMm=$d.ApproxMm }
            }
        }
    }
}
$featureRows | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_part_feature_dimensions.csv') -NoTypeInformation -Encoding UTF8

$missingRows = @($componentRows | Where-Object { $_.MissingReference -eq $true })
$missingRows | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_missing_references.csv') -NoTypeInformation -Encoding UTF8
$inspectionErrors | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_inspection_errors.csv') -NoTypeInformation -Encoding UTF8

$mainReport = @($assemblyReports | Where-Object { $_.Path -ieq $RootAssemblyPath } | Select-Object -First 1)
$summary = [pscustomobject]@{
    GeneratedAt=(Get-Date).ToString('s'); RootAssembly=$RootAssemblyPath; SolidWorksRevision=$revision;
    SldasmFiles=$AssemblyFiles.Count; SldprtFiles=$PartFiles.Count;
    MainAssemblyComponentInstances=$(if($mainReport.Count){$mainReport[0].ComponentCount}else{0});
    MainAssemblyMates=$(if($mainReport.Count){$mainReport[0].MateCount}else{0});
    MissingReferences=$missingRows.Count; PartReportsCompleted=$partReports.Count; Errors=$inspectionErrors.Count
}
$summary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $OutputDir '20in_summary.json') -Encoding UTF8

Write-Host ''
Write-Host '============================================================' -ForegroundColor DarkGray
Write-Host '20in Q347F ASSEMBLY REVERSE INSPECTION V3 COMPLETE' -ForegroundColor Green
Write-Host ("Main assembly components : {0}" -f $summary.MainAssemblyComponentInstances)
Write-Host ("Main assembly mates      : {0}" -f $summary.MainAssemblyMates)
Write-Host ("Unique Pack parts        : {0}" -f $PartFiles.Count)
Write-Host ("Part reports completed   : {0}" -f $partReports.Count)
Write-Host ("Missing references       : {0}" -f $missingRows.Count)
Write-Host ("Inspection warnings      : {0}" -f $inspectionErrors.Count)
Write-Host ("Output folder            : {0}" -f $OutputDir)
Write-Host '============================================================' -ForegroundColor DarkGray

if ($inspectionErrors.Count -gt 0) {
    Write-Host '[WARN] First inspection errors:' -ForegroundColor Yellow
    $inspectionErrors | Select-Object -First 5 | ForEach-Object { Write-Host ("  [{0}] {1} -> {2}" -f $_.Stage,(Split-Path -Leaf $_.File),$_.Error) -ForegroundColor Yellow }
    Write-Host '[WARN] Full list: 20in_inspection_errors.csv' -ForegroundColor Yellow
}
