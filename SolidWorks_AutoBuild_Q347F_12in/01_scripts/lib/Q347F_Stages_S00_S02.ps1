function Initialize-ResumeState {
    $prev = Load-PreviousState
    $script:PreviousState = $prev
    if (-not $Resume -or $null -eq $prev) {
        foreach ($k in $StepNames.Keys) { $script:StepStatus[$k] = 'WAITING' }
        return
    }

    foreach ($k in $StepNames.Keys) {
        $v = $prev.steps.$k
        if ($null -ne $v) { $script:StepStatus[$k] = [string]$v }
    }
    Write-RunLog 'S00' 'RESUME' 0 'RUNNING' ("Resume requested. Previous run={0}" -f $prev.lastRunId)
}

function Should-RunStep([string]$Step) {
    if (-not $Resume) { return $true }
    return ($script:StepStatus[$Step] -ne 'PASS')
}

function Invoke-S00 {
    Set-StepStatus 'S00' 'RUNNING' 'S00 started'
    Write-RunLog 'S00' 'ENV' 0 'RUNNING' 'Checking Windows / PowerShell / SOLIDWORKS API environment.'

    Assert-True ($env:OS -eq 'Windows_NT') 'BLOCKED: this builder must run on Windows.'
    Write-RunLog 'S00' 'POWERSHELL' 1 'PASS' ("PowerShell={0} Edition={1} 64bit={2}" -f $PSVersionTable.PSVersion, $PSVersionTable.PSEdition, [Environment]::Is64BitProcess)
    Assert-True ($PSVersionTable.PSEdition -eq 'Desktop') 'BLOCKED: V1 requires 64-bit Windows PowerShell (powershell.exe). Please run the provided BAT entry point.'
    Assert-True ([Environment]::Is64BitProcess) 'BLOCKED: use 64-bit PowerShell for SOLIDWORKS 2025.'

    Acquire-BuildLock
    Write-RunLog 'S00' 'LOCK' 1 'PASS' ("Build lock acquired. PID={0}" -f $PID)

    $script:SldworksExe = Find-FirstExistingPath @(
        (Join-Path $env:ProgramFiles 'SOLIDWORKS Corp\SOLIDWORKS\SLDWORKS.exe'),
        (Join-Path $env:ProgramFiles 'SOLIDWORKS Corp\SOLIDWORKS 2025\SLDWORKS.exe')
    )
    if (-not $script:SldworksExe) { $script:SldworksExe = Find-SolidWorksFile 'SLDWORKS.exe' }
    Assert-True (-not [string]::IsNullOrWhiteSpace($script:SldworksExe)) 'BLOCKED: SLDWORKS.exe could not be resolved from build_config.json or automatic discovery.'
    Write-RunLog 'S00' 'SW2025' 2 'PASS' ("SLDWORKS.exe={0}" -f $script:SldworksExe)

    $apiRedist = Join-Path (Split-Path -Parent $script:SldworksExe) 'api\redist'
    $script:InteropSldworks = Find-FirstExistingPath @((Join-Path $apiRedist 'SolidWorks.Interop.sldworks.dll'))
    if (-not $script:InteropSldworks) { $script:InteropSldworks = Find-SolidWorksFile 'SolidWorks.Interop.sldworks.dll' }
    Assert-True (-not [string]::IsNullOrWhiteSpace($script:InteropSldworks)) 'BLOCKED: SolidWorks.Interop.sldworks.dll not found.'
    Write-RunLog 'S00' 'INTEROP' 3 'PASS' ("sldworks.dll={0}" -f $script:InteropSldworks)

    $script:InteropSwconst = Find-FirstExistingPath @((Join-Path $apiRedist 'SolidWorks.Interop.swconst.dll'))
    if (-not $script:InteropSwconst) { $script:InteropSwconst = Find-SolidWorksFile 'SolidWorks.Interop.swconst.dll' }
    Assert-True (-not [string]::IsNullOrWhiteSpace($script:InteropSwconst)) 'BLOCKED: SolidWorks.Interop.swconst.dll not found.'
    Write-RunLog 'S00' 'INTEROP' 3 'PASS' ("swconst.dll={0}" -f $script:InteropSwconst)

    $sldAsmVer = [Reflection.AssemblyName]::GetAssemblyName($script:InteropSldworks).Version
    $constAsmVer = [Reflection.AssemblyName]::GetAssemblyName($script:InteropSwconst).Version
    Assert-True ($sldAsmVer.Major -eq $RequiredSwMajorRevision) ("BLOCKED: sldworks interop major version is {0}; expected {1} for SOLIDWORKS 2025." -f $sldAsmVer.Major, $RequiredSwMajorRevision)
    Assert-True ($constAsmVer.Major -eq $RequiredSwMajorRevision) ("BLOCKED: swconst interop major version is {0}; expected {1} for SOLIDWORKS 2025." -f $constAsmVer.Major, $RequiredSwMajorRevision)
    Write-RunLog 'S00' 'INTEROP' 4 'PASS' ("Interop versions: sldworks={0}, swconst={1}" -f $sldAsmVer, $constAsmVer)

    Initialize-SolidWorksInteropAssemblies

    $probe = Join-Path $OutputRoot (".__write_probe_{0}.tmp" -f $RunId)
    'ok' | Set-Content -LiteralPath $probe -Encoding ASCII
    Remove-Item -LiteralPath $probe -Force
    Write-RunLog 'S00' 'OUTPUT' 4 'PASS' ("Writable output={0}" -f $OutputRoot)

    try {
        $drive = [System.IO.DriveInfo]::new([IO.Path]::GetPathRoot((Resolve-Path $AutoRoot).Path))
        $freeGb = [Math]::Round($drive.AvailableFreeSpace / 1GB, 2)
        if ($freeGb -lt 2) {
            Write-RunLog 'S00' 'DISK' 4 'WARN' ("Free space only {0} GB; recommend >=2 GB." -f $freeGb)
            Add-RunWarning ("Low disk space: $freeGb GB")
        } else {
            Write-RunLog 'S00' 'DISK' 4 'PASS' ("Free space={0} GB" -f $freeGb)
        }
    } catch {
        Write-RunLog 'S00' 'DISK' 4 'WARN' ("Disk space query failed: {0}" -f $_.Exception.Message)
        Add-RunWarning 'Disk free-space query failed.'
    }

    Add-EmbeddedSwSessionApiType
    Add-EmbeddedSwEquationApiType
    Add-EmbeddedSwGeometryApiType
    Add-EmbeddedSwValidationApiType
    Write-RunLog 'S00' 'CSHARP' 5 'PASS' ("Embedded C# compiled. ScriptVersion={0}" -f $ScriptVersion)
    Set-StepStatus 'S00' 'PASS' 'S00 PASS'
}

function Invoke-S01 {
    Set-StepStatus 'S01' 'RUNNING' 'S01 started'
    Write-RunLog 'S01' 'PARAM' 5 'RUNNING' ("Reading parameter source: {0}" -f $ParameterFile)
    Assert-True (Test-Path -LiteralPath $ParameterFile) ("BLOCKED: parameter file not found: {0}" -f $ParameterFile)

    Copy-Item -LiteralPath $ParameterFile -Destination $ParameterSnapshotPath -Force
    $script:ParameterHash = Get-FileSha256 $ParameterFile
    Write-RunLog 'S01' 'PARAM' 6 'PASS' ("Parameter snapshot saved. SHA256={0}" -f $script:ParameterHash)

    $resolved = Resolve-Q347FParameters $ParameterFile
    $script:Params = $resolved.Values
    Write-RunLog 'S01' 'PARAM' 7 'PASS' ("Resolved {0} global variables." -f $script:Params.Count)

    $checks = [ordered]@{
        VALVE_F2F = 610.0
        BORE_D = 303.0
        BALL_OD = 465.0
        BALL_R = 232.5
        X_BODY_JOINT_CAD = 232.5
        MAIN_OPENING_D = 480.0
        MID_GASKET_OD = 500.0
        MID_BCD_CAD = 526.5
        UP_BRG_OD = 105.0
        LOWER_BRG_OD = 70.0
        Z_BODY_TOP_IF_CAD = 264.5
        Z_BODY_BOTTOM_IF_CAD = -270.5
        F25_BOLT_PCD = 254.0
        Z_STEM_TOP_CAD = 430.0
    }
    foreach ($name in $checks.Keys) {
        $actual = Get-Param $name
        Assert-Near $name $actual ([double]$checks[$name]) 0.001
        Write-RunLog 'S01' 'PARAM' 8 'PASS' ("{0}={1} mm" -f $name, $actual)
    }

    Assert-Near 'VALVE_F2F/2' ((Get-Param 'VALVE_F2F') / 2.0) 305.0 0.001
    Assert-True ((Get-Param 'MAIN_OPENING_D') -gt (Get-Param 'BALL_OD')) 'BLOCKED: MAIN_OPENING_D must be greater than BALL_OD.'
    Assert-True ((Get-Param 'MID_GASKET_OD') -gt (Get-Param 'MID_GASKET_ID')) 'BLOCKED: MID_GASKET_OD must be greater than MID_GASKET_ID.'
    Assert-True ((Get-Param 'UP_BRG_OD') -gt (Get-Param 'UP_BRG_ID')) 'BLOCKED: UP_BRG_OD must be greater than UP_BRG_ID.'
    Assert-True ((Get-Param 'LOWER_BRG_OD') -gt (Get-Param 'LOWER_BRG_ID')) 'BLOCKED: LOWER_BRG_OD must be greater than LOWER_BRG_ID.'
    Assert-True ((Get-Param 'Z_BODY_TOP_IF_CAD') -gt 0) 'BLOCKED: Z_BODY_TOP_IF_CAD must be positive.'
    Assert-True ((Get-Param 'Z_BODY_BOTTOM_IF_CAD') -lt 0) 'BLOCKED: Z_BODY_BOTTOM_IF_CAD must be negative.'
    Write-RunLog 'S01' 'GEOMETRY' 9 'PASS' 'Geometry logic checks passed: opening>ball, F2F/2, gasket, bearings, top/bottom Z signs.'

    $clearRad = ((Get-Param 'MAIN_OPENING_D') - (Get-Param 'BALL_OD')) / 2.0
    Write-RunLog 'S01' 'GEOMETRY' 10 'PASS' ("BALL through-opening radial clearance={0} mm/side" -f $clearRad)

    $prev = $script:PreviousState
    if ($Resume -and $prev -and $prev.parameterHash -and ([string]$prev.parameterHash -ne $script:ParameterHash)) {
        Write-RunLog 'S01' 'RESUME' 10 'WARN' 'Parameter hash changed since previous run; S03 is marked STALE and will rebuild.'
        Add-RunWarning 'Parameter source changed; downstream skeleton was rebuilt.'
        $script:StepStatus['S03'] = 'WAITING'
    }
    Set-StepStatus 'S01' 'PASS' 'S01 PASS'
}

function Invoke-S02 {
    Set-StepStatus 'S02' 'RUNNING' 'S02 started'
    Write-RunLog 'S02' 'SW2025' 10 'RUNNING' 'Connecting to an existing SOLIDWORKS session; if unavailable, starting a new one.'

    $session = [Q347F.SwSessionApi]::ConnectOrStart()
    $script:SwSession = $session
    $script:SwApp = $session.App
    $script:SwConnectionMode = $session.Mode
    $script:SwRevision = $session.Revision
    $script:SwPid = $session.ProcessId

    Write-RunLog 'S02' 'SW2025' 12 'PASS' ("Connection={0} PID={1} Revision={2} Visible={3}" -f $session.Mode, $session.ProcessId, $session.Revision, $session.Visible)
    if ($session.Mode -eq 'START_NEW') { Start-Sleep -Seconds 2 }
    Write-RunLog 'S02' 'SW2025' 13 'PASS' ("LatestSupportedFileVersion={0}" -f $session.LatestFileVersion)

    $major = 0
    if ($session.Revision -match '^(\d+)\.') { $major = [int]$Matches[1] }
    if ($major -ne $RequiredSwMajorRevision) {
        throw "BLOCKED: connected SOLIDWORKS revision is $($session.Revision); expected SOLIDWORKS 2025 major revision $RequiredSwMajorRevision.x."
    }

    $template = Get-Q347FConfiguredPartTemplate
    if ([string]::IsNullOrWhiteSpace($template)) {
        $template = [Q347F.SwSessionApi]::GetDefaultPartTemplate($session)
    }
    Assert-True (-not [string]::IsNullOrWhiteSpace($template)) 'BLOCKED: SOLIDWORKS default Part template is not configured and build_config.json templates.partTemplatePath is empty.'
    Assert-True (Test-Path -LiteralPath $template) ("BLOCKED: Part template does not exist: {0}" -f $template)
    $script:PartTemplate = $template
    Write-RunLog 'S02' 'TEMPLATE' 14 'PASS' ("Part template={0}" -f $template)

    Write-RunLog 'S02' 'SW2025' 15 'PASS' 'ISldWorks connection is valid and ready for S03.'
    Set-StepStatus 'S02' 'PASS' 'S02 PASS'
}
