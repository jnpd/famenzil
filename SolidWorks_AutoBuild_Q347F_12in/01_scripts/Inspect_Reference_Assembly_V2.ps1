[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RootAssemblyPath,
    [Parameter(Mandatory)][string]$OutputDir,
    [switch]$SkipDeepParts
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AutoRoot = Split-Path -Parent $ScriptDir

. (Join-Path $ScriptDir 'lib\Q347F_Common.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_Config.ps1')
. (Join-Path $ScriptDir 'lib\Q347F_SwSessionApi.ps1')

function Safe-Call([scriptblock]$Action, $Default = $null) {
    try { return & $Action } catch { return $Default }
}

function Get-FeatureNext($Feature) {
    if ($null -eq $Feature) { return $null }
    try { return $Feature.GetNextFeature() } catch { return $null }
}

function Get-SubFeatureFirst($Feature) {
    if ($null -eq $Feature) { return $null }
    try { return $Feature.GetFirstSubFeature() } catch { return $null }
}

function Get-SubFeatureNext($Feature) {
    if ($null -eq $Feature) { return $null }
    try { return $Feature.GetNextSubFeature() } catch { return $null }
}

function Get-FeatureDimensions([object]$Feature, [string]$PartTitle, [string]$PartPath, [int]$Order, [int]$Level, [string]$ParentName) {
    $rows = New-Object System.Collections.Generic.List[object]
    $featureName = Safe-Call { [string]$Feature.Name } ''
    $featureType = Safe-Call { [string]$Feature.GetTypeName2() } ''
    $suppressed = Safe-Call { [bool]$Feature.IsSuppressed() } $false

    $dd = Safe-Call { $Feature.GetFirstDisplayDimension() } $null
    $dimCount = 0
    $guard = 0
    while ($null -ne $dd -and $guard++ -lt 200) {
        try {
            $dim = $dd.GetDimension2(0)
            if ($null -ne $dim) {
                $v = [double]$dim.SystemValue
                $rows.Add([pscustomobject]@{
                    Part=$PartTitle; PartPath=$PartPath; Order=$Order; Level=$Level; Parent=$ParentName;
                    Feature=$featureName; Type=$featureType; Suppressed=$suppressed;
                    Dimension=(Safe-Call { [string]$dim.Name } '');
                    FullName=(Safe-Call { [string]$dim.FullName } '');
                    SystemValue=$v; ApproxMm=($v * 1000.0)
                })
                $dimCount++
            }
        } catch { }
        $dd = Safe-Call { $Feature.GetNextDisplayDimension($dd) } $null
    }

    if ($dimCount -eq 0) {
        $rows.Add([pscustomobject]@{
            Part=$PartTitle; PartPath=$PartPath; Order=$Order; Level=$Level; Parent=$ParentName;
            Feature=$featureName; Type=$featureType; Suppressed=$suppressed;
            Dimension=''; FullName=''; SystemValue=''; ApproxMm=''
        })
    }
    return $rows
}

function Collect-PartFeatureRows([object]$Feature, [int]$Level, [string]$ParentName, [string]$PartTitle, [string]$PartPath, [ref]$OrderRef, [System.Collections.Generic.List[object]]$Rows) {
    if ($null -eq $Feature) { return }
    $OrderRef.Value++
    $thisOrder = [int]$OrderRef.Value
    foreach ($r in (Get-FeatureDimensions -Feature $Feature -PartTitle $PartTitle -PartPath $PartPath -Order $thisOrder -Level $Level -ParentName $ParentName)) {
        $Rows.Add($r)
    }

    $name = Safe-Call { [string]$Feature.Name } ''
    $sub = Get-SubFeatureFirst $Feature
    $guard = 0
    while ($null -ne $sub -and $guard++ -lt 500) {
        Collect-PartFeatureRows -Feature $sub -Level ($Level + 1) -ParentName $name -PartTitle $PartTitle -PartPath $PartPath -OrderRef $OrderRef -Rows $Rows
        $sub = Get-SubFeatureNext $sub
    }
}

function Open-ReferenceDocument([object]$App, [string]$Path, [int]$DocType, [switch]$Lightweight) {
    $full = [IO.Path]::GetFullPath($Path)
    $dir = Split-Path -Parent $full
    if ($dir) { try { [void]$App.SetCurrentWorkingDirectory($dir) } catch { } }

    $model = Safe-Call { $App.GetOpenDocumentByName($full) } $null
    $openedHere = $false
    $errors = 0
    $warnings = 0

    if ($null -eq $model) {
        $options = [int][SolidWorks.Interop.swconst.swOpenDocOptions_e]::swOpenDocOptions_Silent -bor
                   [int][SolidWorks.Interop.swconst.swOpenDocOptions_e]::swOpenDocOptions_ReadOnly
        if ($Lightweight) {
            $options = $options -bor [int][SolidWorks.Interop.swconst.swOpenDocOptions_e]::swOpenDocOptions_OverrideDefaultLoadLightweight -bor
                                  [int][SolidWorks.Interop.swconst.swOpenDocOptions_e]::swOpenDocOptions_LoadLightweight
        }
        $model = $App.OpenDoc6($full, $DocType, $options, '', [ref]$errors, [ref]$warnings)
        $openedHere = $true
    }

    if ($null -eq $model) {
        throw "SOLIDWORKS could not open reference document. OpenErrors=$errors, OpenWarnings=$warnings, Path=$full"
    }

    return [pscustomobject]@{ Model=$model; OpenedHere=$openedHere; Errors=$errors; Warnings=$warnings; FullPath=$full }
}

function Close-ReferenceDocument([object]$App, [object]$Opened) {
    if ($null -eq $Opened -or -not $Opened.OpenedHere) { return }
    try { $App.CloseDoc([string]$Opened.Model.GetTitle()) } catch { }
}

function Get-LevelFromComponentName([string]$Name) {
    if ([string]::IsNullOrWhiteSpace($Name)) { return 0 }
    return ([regex]::Matches($Name, '/')).Count
}

function Get-ParentFromComponentName([string]$Name) {
    if ([string]::IsNullOrWhiteSpace($Name)) { return '' }
    $p = $Name.LastIndexOf('/')
    if ($p -le 0) { return '' }
    return $Name.Substring(0, $p)
}

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
Write-Host 'Q347F 20in REVERSE INSPECTOR V2 - DIRECT POWERSHELL COM' -ForegroundColor Cyan
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
Write-Host '[A01-COMPILE][RUNNING] Session API only...' -ForegroundColor Cyan
Add-EmbeddedSwSessionApiType
Write-Host '[A01-COMPILE][PASS] Session API compiled. Inspectors use direct PowerShell COM.' -ForegroundColor Green

Write-Host '[A01][RUNNING] Connecting to SOLIDWORKS 2025...' -ForegroundColor Cyan
$session = [Q347F.SwSessionApi]::ConnectOrStart()
$app = $session.App
Write-Host ("[A01][PASS] Connection={0} PID={1} Revision={2}" -f $session.Mode,$session.ProcessId,$session.Revision) -ForegroundColor Green

$inspectionErrors = New-Object System.Collections.Generic.List[object]
$assemblyInventory = New-Object System.Collections.Generic.List[object]
$componentRows = New-Object System.Collections.Generic.List[object]
$transformRows = New-Object System.Collections.Generic.List[object]
$mateRows = New-Object System.Collections.Generic.List[object]
$mateEntityRows = New-Object System.Collections.Generic.List[object]

$ai = 0
foreach ($asm in $AssemblyFiles) {
    $ai++
    $isRoot = $asm.FullName -ieq $RootAssemblyPath
    Write-Host ("[A02][RUNNING] Assembly {0}/{1}: {2}" -f $ai,$AssemblyFiles.Count,$asm.Name) -ForegroundColor Cyan
    $opened = $null
    try {
        $opened = Open-ReferenceDocument -App $app -Path $asm.FullName -DocType ([int][SolidWorks.Interop.swconst.swDocumentTypes_e]::swDocASSEMBLY) -Lightweight
        $model = $opened.Model
        $assyDoc = $model
        $title = [string]$model.GetTitle()
        $cfg = Safe-Call { [string]$model.ConfigurationManager.ActiveConfiguration.Name } ''
        $lwCount = Safe-Call { [int]$assyDoc.GetLightWeightComponentCount() } -1
        $components = @(Safe-Call { $assyDoc.GetComponents($false) } @())
        $compCount = 0
        $missing = 0

        foreach ($c in $components) {
            if ($null -eq $c) { continue }
            $compCount++
            $name = Safe-Call { [string]$c.Name2 } ''
            $path = Safe-Call { [string]$c.GetPathName() } ''
            $missingRef = (-not [string]::IsNullOrWhiteSpace($path)) -and (-not (Test-Path -LiteralPath $path))
            if ($missingRef) { $missing++ }
            $tx=0.0; $ty=0.0; $tz=0.0
            $r = @()
            try {
                $tr = $c.Transform2
                if ($null -ne $tr) { $r = @($tr.ArrayData) }
                if ($r.Count -ge 12) { $tx=[double]$r[9]*1000; $ty=[double]$r[10]*1000; $tz=[double]$r[11]*1000 }
            } catch { }

            $componentRows.Add([pscustomobject]@{
                Assembly=$title; AssemblyPath=$opened.FullPath; Order=$compCount; Level=(Get-LevelFromComponentName $name);
                Parent=(Get-ParentFromComponentName $name); Component=$name; ComponentPath=$path;
                Configuration=(Safe-Call { [string]$c.ReferencedConfiguration } '');
                DocumentType=(Safe-Call { [int]$c.GetType() } 0); SuppressionState=(Safe-Call { [int]$c.GetSuppression() } -1);
                Hidden=(Safe-Call { [bool]$c.IsHidden($true) } $false); Fixed=(Safe-Call { [bool]$c.IsFixed() } $false);
                MissingReference=$missingRef; X_mm=$tx; Y_mm=$ty; Z_mm=$tz
            })
            $transformRows.Add([pscustomobject]@{
                Assembly=$title; Component=$name; ComponentPath=$path;
                R11=$(if($r.Count-gt 0){$r[0]}else{$null}); R12=$(if($r.Count-gt 1){$r[1]}else{$null}); R13=$(if($r.Count-gt 2){$r[2]}else{$null});
                R21=$(if($r.Count-gt 3){$r[3]}else{$null}); R22=$(if($r.Count-gt 4){$r[4]}else{$null}); R23=$(if($r.Count-gt 5){$r[5]}else{$null});
                R31=$(if($r.Count-gt 6){$r[6]}else{$null}); R32=$(if($r.Count-gt 7){$r[7]}else{$null}); R33=$(if($r.Count-gt 8){$r[8]}else{$null});
                X_mm=$tx; Y_mm=$ty; Z_mm=$tz; Scale=$(if($r.Count-gt 12){$r[12]}else{$null})
            })
        }

        $mateCount = 0
        $feature = Safe-Call { $model.FirstFeature() } $null
        $fg = 0
        while ($null -ne $feature -and $fg++ -lt 5000) {
            $ftype = Safe-Call { [string]$feature.GetTypeName2() } ''
            if ($ftype -ieq 'MateGroup') {
                $sub = Get-SubFeatureFirst $feature
                $sg = 0
                while ($null -ne $sub -and $sg++ -lt 5000) {
                    $stype = Safe-Call { [string]$sub.GetTypeName2() } ''
                    if ($stype -like 'Mate*') {
                        $mateCount++
                        $mname = Safe-Call { [string]$sub.Name } ''
                        $mate = Safe-Call { $sub.GetSpecificFeature2() } $null
                        $entityNames = New-Object System.Collections.Generic.List[string]
                        $entityCount = 0
                        if ($null -ne $mate) {
                            $entityCount = Safe-Call { [int]$mate.GetMateEntityCount() } 0
                            for ($mi=0; $mi -lt $entityCount; $mi++) {
                                $e = Safe-Call { $mate.MateEntity($mi) } $null
                                if ($null -eq $e) { continue }
                                $rc = Safe-Call { $e.ReferenceComponent } $null
                                $cn = if ($null -ne $rc) { Safe-Call { [string]$rc.Name2 } '' } else { '' }
                                $cp = if ($null -ne $rc) { Safe-Call { [string]$rc.GetPathName() } '' } else { '' }
                                if ($cn) { $entityNames.Add($cn) } else { $entityNames.Add('<assembly/reference>') }
                                $mateEntityRows.Add([pscustomobject]@{
                                    Assembly=$title; Mate=$mname; MateType=$stype; EntityIndex=$mi; Component=$cn; ComponentPath=$cp;
                                    ReferenceType=(Safe-Call { [int]$e.ReferenceType2 } 0);
                                    EntityParams=(@(Safe-Call { $e.EntityParams } @()) -join ';')
                                })
                            }
                        }
                        $mateRows.Add([pscustomobject]@{
                            Assembly=$title; AssemblyPath=$opened.FullPath; Order=$mateCount; Mate=$mname; Type=$stype;
                            Suppressed=(Safe-Call { [bool]$sub.IsSuppressed() } $false);
                            Alignment=$(if($null-ne $mate){Safe-Call { [int]$mate.Alignment } 0}else{0});
                            EntityCount=$entityCount; Components=($entityNames -join ' <-> '); Dimensions=''
                        })
                    }
                    $sub = Get-SubFeatureNext $sub
                }
            }
            $feature = Get-FeatureNext $feature
        }

        $assemblyInventory.Add([pscustomobject]@{
            Assembly=$title; Path=$opened.FullPath; Configuration=$cfg; Components=$compCount; Mates=$mateCount;
            MissingReferences=$missing; LightweightComponents=$lwCount; OpenErrors=$opened.Errors; OpenWarnings=$opened.Warnings; IsRoot=$isRoot
        })
        Write-Host ("[A02][PASS] Components={0}; Mates={1}; MissingRefs={2}; Lightweight={3}" -f $compCount,$mateCount,$missing,$lwCount) -ForegroundColor Green
    }
    catch {
        $inspectionErrors.Add([pscustomobject]@{ Stage='ASSEMBLY'; File=$asm.FullName; Error=$_.Exception.Message })
        Write-Host ("[A02][WARN] {0}: {1}" -f $asm.Name,$_.Exception.Message) -ForegroundColor Yellow
    }
    finally { if ($null -ne $opened) { Close-ReferenceDocument -App $app -Opened $opened } }
}

$partInventory = New-Object System.Collections.Generic.List[object]
$featureRows = New-Object System.Collections.Generic.List[object]
if (-not $SkipDeepParts) {
    $pi=0
    foreach ($part in $PartFiles) {
        $pi++
        Write-Host ("[A03][RUNNING] Part {0}/{1}: {2}" -f $pi,$PartFiles.Count,$part.Name) -ForegroundColor Cyan
        $opened=$null
        try {
            $opened = Open-ReferenceDocument -App $app -Path $part.FullName -DocType ([int][SolidWorks.Interop.swconst.swDocumentTypes_e]::swDocPART)
            $model=$opened.Model
            $title=[string]$model.GetTitle()
            $cfg=Safe-Call { [string]$model.ConfigurationManager.ActiveConfiguration.Name } ''
            $b=@(Safe-Call { $model.GetPartBox($true) } @())
            $bodies=@(Safe-Call { $model.GetBodies2([int][SolidWorks.Interop.swconst.swBodyType_e]::swSolidBody,$true) } @())
            $eq=@()
            try {
                $mgr=$model.GetEquationMgr(); if($null-ne $mgr){$n=[int]$mgr.GetCount(); for($i=0;$i-lt$n;$i++){try{$eq += [string]$mgr.Equation($i)}catch{}}}
            } catch { }
            $mat=@(Safe-Call { $model.MaterialPropertyValues } @())

            $localRows = New-Object System.Collections.Generic.List[object]
            $order=0
            $f=Safe-Call { $model.FirstFeature() } $null
            $guard=0
            while($null-ne$f -and $guard++ -lt 2000){
                Collect-PartFeatureRows -Feature $f -Level 0 -ParentName '' -PartTitle $title -PartPath $opened.FullPath -OrderRef ([ref]$order) -Rows $localRows
                $f=Get-FeatureNext $f
            }
            foreach($row in $localRows){$featureRows.Add($row)}

            $partInventory.Add([pscustomobject]@{
                Part=$title; Path=$opened.FullPath; Configuration=$cfg; Features=$order; SolidBodies=$bodies.Count;
                XMin_mm=$(if($b.Count-ge6){[double]$b[0]*1000}else{$null}); YMin_mm=$(if($b.Count-ge6){[double]$b[1]*1000}else{$null}); ZMin_mm=$(if($b.Count-ge6){[double]$b[2]*1000}else{$null});
                XMax_mm=$(if($b.Count-ge6){[double]$b[3]*1000}else{$null}); YMax_mm=$(if($b.Count-ge6){[double]$b[4]*1000}else{$null}); ZMax_mm=$(if($b.Count-ge6){[double]$b[5]*1000}else{$null});
                Equations=($eq -join ' | '); MaterialPropertyValues=($mat -join ';'); OpenErrors=$opened.Errors; OpenWarnings=$opened.Warnings
            })
            Write-Host ("[A03][PASS] Features={0}; SolidBodies={1}" -f $order,$bodies.Count) -ForegroundColor Green
        }
        catch {
            $inspectionErrors.Add([pscustomobject]@{ Stage='PART'; File=$part.FullName; Error=$_.Exception.Message })
            Write-Host ("[A03][WARN] {0}: {1}" -f $part.Name,$_.Exception.Message) -ForegroundColor Yellow
        }
        finally { if($null-ne$opened){Close-ReferenceDocument -App $app -Opened $opened} }
    }
}

$assemblyInventory | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_assembly_inventory.csv') -NoTypeInformation -Encoding UTF8
$componentRows | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_component_tree.csv') -NoTypeInformation -Encoding UTF8
$transformRows | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_transforms.csv') -NoTypeInformation -Encoding UTF8
$mateRows | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_mates.csv') -NoTypeInformation -Encoding UTF8
$mateEntityRows | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_mate_entities.csv') -NoTypeInformation -Encoding UTF8
@($componentRows | Where-Object {$_.MissingReference}) | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_missing_references.csv') -NoTypeInformation -Encoding UTF8
$partInventory | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_part_inventory.csv') -NoTypeInformation -Encoding UTF8
$featureRows | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_part_feature_dimensions.csv') -NoTypeInformation -Encoding UTF8
$inspectionErrors | Export-Csv -LiteralPath (Join-Path $OutputDir '20in_inspection_errors.csv') -NoTypeInformation -Encoding UTF8

$rootReport=@($assemblyInventory | Where-Object {$_.Path -ieq $RootAssemblyPath} | Select-Object -First 1)
$missingRows=@($componentRows | Where-Object {$_.MissingReference})
$summary=[pscustomobject]@{
    GeneratedAt=(Get-Date).ToString('s'); Engine='V2_DIRECT_POWERSHELL_COM'; MainAssembly=$RootAssemblyPath; SolidWorksRevision=$session.Revision;
    SldasmFiles=$AssemblyFiles.Count; SldprtFiles=$PartFiles.Count;
    MainAssemblyComponentInstances=$(if($rootReport.Count){$rootReport[0].Components}else{0});
    MainAssemblyMates=$(if($rootReport.Count){$rootReport[0].Mates}else{0});
    MissingReferences=$missingRows.Count; DeepPartReports=$partInventory.Count; Errors=$inspectionErrors.Count
}
$summary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $OutputDir '20in_summary.json') -Encoding UTF8

$tree=@($componentRows | Where-Object {$_.AssemblyPath -ieq $RootAssemblyPath} | Sort-Object Order | ForEach-Object {
    ('  ' * [int]$_.Level) + ('{0:000}. {1} @ ({2:N3}, {3:N3}, {4:N3}) mm' -f $_.Order,$_.Component,$_.X_mm,$_.Y_mm,$_.Z_mm)
})
$tree | Set-Content -LiteralPath (Join-Path $OutputDir '20in_top_component_tree.txt') -Encoding UTF8

Write-Host ''
Write-Host '============================================================' -ForegroundColor DarkGray
Write-Host '20in Q347F ASSEMBLY REVERSE INSPECTION V2 COMPLETE' -ForegroundColor Green
Write-Host ("Main assembly components : {0}" -f $summary.MainAssemblyComponentInstances)
Write-Host ("Main assembly mates      : {0}" -f $summary.MainAssemblyMates)
Write-Host ("Unique Pack parts        : {0}" -f $PartFiles.Count)
Write-Host ("Part reports completed   : {0}" -f $partInventory.Count)
Write-Host ("Missing references       : {0}" -f $missingRows.Count)
Write-Host ("Inspection warnings      : {0}" -f $inspectionErrors.Count)
Write-Host ("Output folder            : {0}" -f $OutputDir)
Write-Host '============================================================' -ForegroundColor DarkGray

if($inspectionErrors.Count -gt 0){
    Write-Host '[WARN] First inspection errors:' -ForegroundColor Yellow
    @($inspectionErrors | Select-Object -First 5) | ForEach-Object { Write-Host ("  [{0}] {1} -> {2}" -f $_.Stage,(Split-Path $_.File -Leaf),$_.Error) -ForegroundColor Yellow }
    Write-Host '[WARN] Full list: 20in_inspection_errors.csv' -ForegroundColor Yellow
}

exit 0
