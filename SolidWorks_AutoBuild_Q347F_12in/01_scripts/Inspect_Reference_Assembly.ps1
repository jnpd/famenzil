[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$SourcePath,
    [string]$OutputDir,
    [switch]$SkipDeepParts
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AutoRoot = Split-Path -Parent $ScriptDir
$BuildName = 'Q347F 20IN REFERENCE ASSEMBLY INSPECTOR'
$StepNames = @{ REFASM='REFERENCE_ASSEMBLY_INSPECT' }
$MainLog = Join-Path $AutoRoot '04_logs\reference_assembly_inspector.log'

. (Join-Path $ScriptDir 'lib\Q347F_Common.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_Config.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_SwSessionApi.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_SwReferenceInspectorApi.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_SwAssemblyInspectorApi.ps1')

$SourcePath = [Environment]::ExpandEnvironmentVariables($SourcePath)
if (-not (Test-Path -LiteralPath $SourcePath)) { throw "Source not found: $SourcePath" }
$SourcePath = (Resolve-Path -LiteralPath $SourcePath).Path

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path $AutoRoot ('04_logs\reference_assembly_{0}' -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
}
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

function Resolve-PackRoot([string]$InputPath) {
    if (Test-Path -LiteralPath $InputPath -PathType Container) { return $InputPath }
    $ext = [IO.Path]::GetExtension($InputPath)
    if ($ext -ieq '.zip') {
        $extract = Join-Path $OutputDir 'pack_and_go_extracted'
        if (Test-Path -LiteralPath $extract) { Remove-Item -LiteralPath $extract -Recurse -Force }
        New-Item -ItemType Directory -Force -Path $extract | Out-Null
        Write-Host ("[A00][RUNNING] Extracting Pack and Go ZIP: {0}" -f $InputPath) -ForegroundColor Cyan
        Expand-Archive -LiteralPath $InputPath -DestinationPath $extract -Force
        Write-Host ("[A00][PASS] ZIP extracted to: {0}" -f $extract) -ForegroundColor Green
        return $extract
    }
    if ($ext -ieq '.sldasm') { return (Split-Path -Parent $InputPath) }
    throw 'SourcePath must be a Pack and Go folder, .zip, or .SLDASM.'
}

function Find-MainAssembly([string]$Root, [string]$InputPath) {
    if ((Test-Path -LiteralPath $InputPath -PathType Leaf) -and ([IO.Path]::GetExtension($InputPath) -ieq '.sldasm')) {
        return $InputPath
    }
    $all = @(Get-ChildItem -LiteralPath $Root -Recurse -File -Filter '*.SLDASM')
    if ($all.Count -eq 0) { throw "No .SLDASM files found under: $Root" }

    $exact = @($all | Where-Object { $_.Name -ieq '20Q347F-300LB 总装图.SLDASM' })
    if ($exact.Count -gt 0) { return $exact[0].FullName }

    $preferred = @($all | Where-Object { $_.Name -match '总装' -and $_.Name -notmatch '副本|copy' } | Sort-Object Length)
    if ($preferred.Count -gt 0) { return $preferred[0].FullName }

    return ($all | Sort-Object Length | Select-Object -First 1).FullName
}

$PackRoot = Resolve-PackRoot $SourcePath
$MainAssembly = Find-MainAssembly $PackRoot $SourcePath
$AssemblyFiles = @(Get-ChildItem -LiteralPath $PackRoot -Recurse -File -Filter '*.SLDASM' | Sort-Object FullName)
$PartFiles = @(Get-ChildItem -LiteralPath $PackRoot -Recurse -File -Filter '*.SLDPRT' | Sort-Object FullName)

Write-Host ''
Write-Host '============================================================' -ForegroundColor DarkGray
Write-Host 'Q347F 20in PACK AND GO INVENTORY' -ForegroundColor Cyan
Write-Host ("Root assembly : {0}" -f $MainAssembly)
Write-Host ("SLDASM files  : {0}" -f $AssemblyFiles.Count)
Write-Host ("SLDPRT files  : {0}" -f $PartFiles.Count)
Write-Host ("Output        : {0}" -f $OutputDir)
Write-Host '============================================================' -ForegroundColor DarkGray

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
Add-EmbeddedSwAssemblyInspectorApiType

Write-Host '[A01][RUNNING] Connecting to SOLIDWORKS 2025...' -ForegroundColor Cyan
$session = [Q347F.SwSessionApi]::ConnectOrStart()
Write-Host ("[A01][PASS] Connection={0} PID={1} Revision={2}" -f $session.Mode, $session.ProcessId, $session.Revision) -ForegroundColor Green

$inspectionErrors = New-Object System.Collections.Generic.List[object]
$assemblyReports = New-Object System.Collections.Generic.List[object]
$ai = 0
foreach ($asm in $AssemblyFiles) {
    $ai++
    Write-Host ("[A02][RUNNING] Assembly {0}/{1}: {2}" -f $ai, $AssemblyFiles.Count, $asm.Name) -ForegroundColor Cyan
    try {
        $r = [Q347F.SwAssemblyInspectorApi]::Inspect($session, $asm.FullName)
        $assemblyReports.Add($r)
        Write-Host ("[A02][PASS] Components={0}; Mates={1}; MissingRefs={2}; Lightweight={3}" -f $r.ComponentCount,$r.MateCount,$r.MissingReferenceCount,$r.LightweightComponentCount) -ForegroundColor Green
    }
    catch {
        $inspectionErrors.Add([pscustomobject]@{ Stage='ASSEMBLY'; File=$asm.FullName; Error=$_.Exception.Message })
        Write-Host ("[A02][WARN] {0}: {1}" -f $asm.Name, $_.Exception.Message) -ForegroundColor Yellow
    }
}

$asmInventory = foreach ($r in $assemblyReports) {
    [pscustomobject]@{
        Assembly=$r.Title; Path=$r.Path; Configuration=$r.ActiveConfiguration;
        Components=$r.ComponentCount; Mates=$r.MateCount; MissingReferences=$r.MissingReferenceCount;
        LightweightComponents=$r.LightweightComponentCount; OpenErrors=$r.OpenErrors; OpenWarnings=$r.OpenWarnings
    }
}
$asmInventory | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_assembly_inventory.csv') -NoTypeInformation -Encoding UTF8

$componentRows = foreach ($r in $assemblyReports) {
    foreach ($c in $r.Components) {
        [pscustomobject]@{
            Assembly=$r.Title; AssemblyPath=$r.Path; Order=$c.Order; Level=$c.Level; Parent=$c.ParentName;
            Component=$c.Name; ComponentPath=$c.Path; Configuration=$c.ReferencedConfiguration;
            DocumentType=$c.DocumentType; SuppressionState=$c.SuppressionState; Hidden=$c.Hidden; Fixed=$c.Fixed;
            MissingReference=$c.MissingReference; X_mm=$c.TxMm; Y_mm=$c.TyMm; Z_mm=$c.TzMm
        }
    }
}
$componentRows | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_component_tree.csv') -NoTypeInformation -Encoding UTF8

$transformRows = foreach ($r in $assemblyReports) {
    foreach ($c in $r.Components) {
        $t = @($c.Transform)
        [pscustomobject]@{
            Assembly=$r.Title; Component=$c.Name; ComponentPath=$c.Path;
            R11=$(if($t.Count -gt 0){$t[0]}else{$null}); R12=$(if($t.Count -gt 1){$t[1]}else{$null}); R13=$(if($t.Count -gt 2){$t[2]}else{$null});
            R21=$(if($t.Count -gt 3){$t[3]}else{$null}); R22=$(if($t.Count -gt 4){$t[4]}else{$null}); R23=$(if($t.Count -gt 5){$t[5]}else{$null});
            R31=$(if($t.Count -gt 6){$t[6]}else{$null}); R32=$(if($t.Count -gt 7){$t[7]}else{$null}); R33=$(if($t.Count -gt 8){$t[8]}else{$null});
            X_mm=$c.TxMm; Y_mm=$c.TyMm; Z_mm=$c.TzMm; Scale=$(if($t.Count -gt 12){$t[12]}else{$null})
        }
    }
}
$transformRows | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_transforms.csv') -NoTypeInformation -Encoding UTF8

$mateRows = foreach ($r in $assemblyReports) {
    foreach ($m in $r.Mates) {
        $entityNames = @($m.Entities | ForEach-Object { if ($_.ComponentName) { $_.ComponentName } else { '<assembly/reference>' } }) -join ' <-> '
        $dims = @($m.Dimensions | ForEach-Object { '{0}={1:N3}mm' -f $_.Name,$_.ApproxMm }) -join '; '
        [pscustomobject]@{
            Assembly=$r.Title; AssemblyPath=$r.Path; Order=$m.Order; Mate=$m.Name; Type=$m.TypeName;
            Suppressed=$m.Suppressed; Alignment=$m.Alignment; EntityCount=$m.Entities.Count; Components=$entityNames; Dimensions=$dims
        }
    }
}
$mateRows | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_mates.csv') -NoTypeInformation -Encoding UTF8

$mateEntityRows = foreach ($r in $assemblyReports) {
    foreach ($m in $r.Mates) {
        foreach ($e in $m.Entities) {
            [pscustomobject]@{
                Assembly=$r.Title; Mate=$m.Name; MateType=$m.TypeName; EntityIndex=$e.Index;
                Component=$e.ComponentName; ComponentPath=$e.ComponentPath; ReferenceType=$e.ReferenceType;
                EntityParams=(@($e.EntityParams) -join ';')
            }
        }
    }
}
$mateEntityRows | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_mate_entities.csv') -NoTypeInformation -Encoding UTF8

$missingRows = @($componentRows | Where-Object { $_.MissingReference -eq $true })
$missingRows | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_missing_references.csv') -NoTypeInformation -Encoding UTF8

$partReports = New-Object System.Collections.Generic.List[object]
if (-not $SkipDeepParts) {
    $pi = 0
    foreach ($part in $PartFiles) {
        $pi++
        Write-Host ("[A03][RUNNING] Part {0}/{1}: {2}" -f $pi,$PartFiles.Count,$part.Name) -ForegroundColor Cyan
        try {
            $pr = [Q347F.SwReferenceInspectorApi]::Inspect($session, $part.FullName)
            $partReports.Add($pr)
            Write-Host ("[A03][PASS] Features={0}; SolidBodies={1}" -f $pr.FeatureCount,$pr.SolidBodyCount) -ForegroundColor Green
        }
        catch {
            $inspectionErrors.Add([pscustomobject]@{ Stage='PART'; File=$part.FullName; Error=$_.Exception.Message })
            Write-Host ("[A03][WARN] {0}: {1}" -f $part.Name,$_.Exception.Message) -ForegroundColor Yellow
        }
    }
}

$partInventory = foreach ($p in $partReports) {
    $b = @($p.BoundingBoxMm)
    [pscustomobject]@{
        Part=$p.Title; Path=$p.Path; Configuration=$p.ActiveConfiguration; Features=$p.FeatureCount; SolidBodies=$p.SolidBodyCount;
        XMin_mm=$(if($b.Count-ge 6){$b[0]}else{$null}); YMin_mm=$(if($b.Count-ge 6){$b[1]}else{$null}); ZMin_mm=$(if($b.Count-ge 6){$b[2]}else{$null});
        XMax_mm=$(if($b.Count-ge 6){$b[3]}else{$null}); YMax_mm=$(if($b.Count-ge 6){$b[4]}else{$null}); ZMax_mm=$(if($b.Count-ge 6){$b[5]}else{$null});
        Equations=(@($p.Equations) -join ' | '); MaterialPropertyValues=(@($p.MaterialPropertyValues) -join ';')
    }
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

$mainReport = @($assemblyReports | Where-Object { $_.Path -ieq $MainAssembly } | Select-Object -First 1)
$summary = [pscustomobject]@{
    GeneratedAt=(Get-Date).ToString('s')
    Source=$SourcePath
    PackRoot=$PackRoot
    MainAssembly=$MainAssembly
    SolidWorksRevision=$session.Revision
    SldasmFiles=$AssemblyFiles.Count
    SldprtFiles=$PartFiles.Count
    MainAssemblyComponentInstances=$(if($mainReport.Count){$mainReport[0].ComponentCount}else{0})
    MainAssemblyMates=$(if($mainReport.Count){$mainReport[0].MateCount}else{0})
    MissingReferences=$missingRows.Count
    DeepPartReports=$partReports.Count
    Errors=$inspectionErrors.Count
    Outputs=@(
        '20in_assembly_inventory.csv','20in_component_tree.csv','20in_transforms.csv','20in_mates.csv','20in_mate_entities.csv',
        '20in_missing_references.csv','20in_part_inventory.csv','20in_part_feature_dimensions.csv','20in_inspection_errors.csv'
    )
}
$summary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $OutputDir '20in_summary.json') -Encoding UTF8
$inspectionErrors | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_inspection_errors.csv') -NoTypeInformation -Encoding UTF8

$tree = @($componentRows | Where-Object { $_.AssemblyPath -ieq $MainAssembly } | Sort-Object Order | ForEach-Object {
    ('  ' * [int]$_.Level) + ('{0:000}. {1}  @ ({2:N3}, {3:N3}, {4:N3}) mm' -f $_.Order,$_.Component,$_.X_mm,$_.Y_mm,$_.Z_mm)
})
$tree | Set-Content -LiteralPath (Join-Path $OutputDir '20in_top_component_tree.txt') -Encoding UTF8

Write-Host ''
Write-Host '============================================================' -ForegroundColor DarkGray
Write-Host '20in Q347F ASSEMBLY REVERSE INSPECTION COMPLETE' -ForegroundColor Green
Write-Host ("Main assembly components : {0}" -f $summary.MainAssemblyComponentInstances)
Write-Host ("Main assembly mates      : {0}" -f $summary.MainAssemblyMates)
Write-Host ("Unique Pack parts        : {0}" -f $PartFiles.Count)
Write-Host ("Part reports completed   : {0}" -f $partReports.Count)
Write-Host ("Missing references       : {0}" -f $missingRows.Count)
Write-Host ("Inspection warnings      : {0}" -f $inspectionErrors.Count)
Write-Host ("Output folder            : {0}" -f $OutputDir)
Write-Host '============================================================' -ForegroundColor DarkGray

if ($inspectionErrors.Count -gt 0) {
    Write-Host '[WARN] Core exports were preserved. Check 20in_inspection_errors.csv for individual files that could not be inspected.' -ForegroundColor Yellow
}
