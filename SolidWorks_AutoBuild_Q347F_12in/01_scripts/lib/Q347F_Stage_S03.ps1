function Invoke-S03 {
    Set-StepStatus 'S03' 'RUNNING' 'S03 started'
    Write-RunLog 'S03' 'SKELETON' 15 'RUNNING' 'Creating 00_SKELETON.SLDPRT in run staging area.'

    $model = $null
    try {
        $model = [Q347F.SwSessionApi]::NewPart($script:SwSession, $script:PartTemplate)
        Write-RunLog 'S03' 'SKELETON' 16 'PASS' 'New Part created from the configured SOLIDWORKS 2025 template.'

        $eqCount = [Q347F.SwEquationApi]::ImportOrUpdateEquations($model, $ParameterFile)
        Write-RunLog 'S03' 'EQUATIONS' 17 'PASS' ("Global variables imported/updated. EquationCount={0}" -f $eqCount)

        $basePlanes = [Q347F.SwGeometryApi]::CreateProjectBasePlanes($model)
        Write-RunLog 'S03' 'BASES' 18 'PASS' ("Project base planes created: {0}" -f ($basePlanes -join ', '))

        $axes = [Q347F.SwGeometryApi]::CreateProjectAxes($model)
        Write-RunLog 'S03' 'AXES' 18 'PASS' ("Named axes created: {0}" -f ($axes -join ', '))

        $centerSketch = [Q347F.SwGeometryApi]::CreateBallCenterPoint($model)
        Write-RunLog 'S03' 'ORIGIN' 18 'PASS' ("BALL_CENTER_O=(0,0,0) created as {0}." -f $centerSketch)

        $xStations = @(
            -(Get-Param 'HALF_F2F'),
            (Get-Param 'X_END_FLANGE_BACK_L_CAD'),
            -(Get-Param 'BALL_R'),
            (Get-Param 'BALL_X_L'),
            (Get-Param 'X_CONTACT_L'),
            0.0,
            (Get-Param 'X_CONTACT_R'),
            (Get-Param 'BALL_X_R'),
            (Get-Param 'X_BODY_JOINT_CAD'),
            (Get-Param 'X_END_FLANGE_BACK_R_CAD'),
            (Get-Param 'X_END_FACE_R')
        )
        $zStations = @(
            (Get-Param 'Z_BOTTOM_COVER_OUTER_REF_CAD'),
            (Get-Param 'Z_BODY_BOTTOM_IF_CAD'),
            (Get-Param 'Z_BOTTOM_JOURNAL_PILOT_SHOULDER_CAD'),
            (Get-Param 'LOWER_BRG_Z_OUT'),
            (Get-Param 'LOWER_BRG_Z_IN'),
            0.0,
            (Get-Param 'UP_BRG_Z0'),
            (Get-Param 'UP_BRG_Z1'),
            (Get-Param 'Z_TOP_JOURNAL_PILOT_SHOULDER_CAD'),
            (Get-Param 'Z_BODY_TOP_IF_CAD'),
            (Get-Param 'Z_TOP_COVER_OUTER_REF_CAD'),
            (Get-Param 'Z_ADAPTER_BOTTOM_CAD'),
            (Get-Param 'Z_F25_INTERFACE_CAD'),
            (Get-Param 'Z_KEY_START_CAD'),
            (Get-Param 'Z_KEY_END_CAD'),
            (Get-Param 'Z_STEM_TOP_CAD')
        )

        $createdPlanes = New-Object System.Collections.Generic.List[object]
        $idx = 0
        foreach ($x in $xStations) {
            $name = Convert-StationName 'X' ([double]$x)
            [void][Q347F.SwGeometryApi]::CreateStationPlane($model, 'X', [double]$x, $name)
            $idx++
            $pct = 18 + [int][Math]::Floor(($idx / [double]($xStations.Count + $zStations.Count)) * 4)
            Write-RunLog 'S03' 'X_STATION' $pct 'PASS' ("{0} created at X={1} mm" -f $name, $x)
            $createdPlanes.Add([pscustomobject]@{ Axis='X'; Name=$name; Expected=[double]$x })
        }
        foreach ($z in $zStations) {
            $name = Convert-StationName 'Z' ([double]$z)
            [void][Q347F.SwGeometryApi]::CreateStationPlane($model, 'Z', [double]$z, $name)
            $idx++
            $pct = 18 + [int][Math]::Floor(($idx / [double]($xStations.Count + $zStations.Count)) * 4)
            Write-RunLog 'S03' 'Z_STATION' $pct 'PASS' ("{0} created at Z={1} mm" -f $name, $z)
            $createdPlanes.Add([pscustomobject]@{ Axis='Z'; Name=$name; Expected=[double]$z })
        }

        $x0Name = Convert-StationName 'X' 0
        $zf25Name = Convert-StationName 'Z' (Get-Param 'Z_F25_INTERFACE_CAD')
        [void][Q347F.SwGeometryApi]::CreateEnvelopeSketch($model, $x0Name, 'SK_ENV_X0_BALL_BORE_BODY_MIDFLANGE', @(
            (Get-Param 'BALL_OD'),
            (Get-Param 'BORE_D'),
            (Get-Param 'BODY_OUTER_D_CENTRAL_CAD'),
            (Get-Param 'MID_FLANGE_OD_CAD')
        ))
        Write-RunLog 'S03' 'ENVELOPE' 22 'PASS' 'X=0 construction envelope sketch created: BALL D465 / BORE D303 / BODY D504 / MID FLANGE D562.5.'

        [void][Q347F.SwGeometryApi]::CreateEnvelopeSketch($model, $zf25Name, 'SK_ENV_F25_OD', @((Get-Param 'ADAPTER_OD_CAD')))
        Write-RunLog 'S03' 'ENVELOPE' 22 'PASS' ("F25 construction envelope sketch created: OD D{0} at Z={1} mm." -f (Get-Param 'ADAPTER_OD_CAD'), (Get-Param 'Z_F25_INTERFACE_CAD'))

        Write-RunLog 'S03' 'READBACK' 22 'RUNNING' 'Forcing rebuild before independent world-coordinate readback of all X/Z station planes.'
        $readbackRebuildOk = [Q347F.SwGeometryApi]::RebuildForReadback($model)
        Assert-True $readbackRebuildOk 'Rebuild failed before station-plane coordinate readback.'

        foreach ($p in $createdPlanes) {
            Assert-True ([Q347F.SwValidationApi]::FeatureExists($model, $p.Name)) ("Missing required reference plane after creation: {0}" -f $p.Name)
            if ([Math]::Abs($p.Expected) -gt 0.0001) {
                $readSigned = [Q347F.SwGeometryApi]::ReadPlaneCoordinateMm($model, $p.Name, $p.Axis)
                Assert-Near ("Readback {0}" -f $p.Name) $readSigned $p.Expected 0.01
            }
        }
        Write-RunLog 'S03' 'READBACK' 23 'PASS' ("Required station planes verified by feature name and world-coordinate readback. X={0}, Z={1}." -f $xStations.Count, $zStations.Count)

        $validation = [Q347F.SwValidationApi]::Validate($model)
        if (-not $validation.RebuildOk) {
            throw 'Rebuild failed: IModelDoc2.ForceRebuild3 returned false.'
        }
        foreach ($item in $validation.Items) {
            $s = if ($item.IsWarning) { 'WARN' } else { 'FAIL' }
            $msg = "Feature=$($item.FeatureName) Type=$($item.FeatureType) ErrorCode=$($item.ErrorCode)"
            Write-RunLog 'S03' 'WHATS_WRONG' 24 $s $msg
            if ($item.IsWarning) { Add-RunWarning $msg } else { Add-RunError $msg }
        }
        if ($validation.ErrorCount -gt 0) {
            throw "What's Wrong / feature validation found $($validation.ErrorCount) error(s)."
        }
        if ($validation.WarningCount -gt 0) {
            Write-RunLog 'S03' 'WHATS_WRONG' 24 'WARN' ("Rebuild PASS; feature errors=0; warnings={0}." -f $validation.WarningCount)
        } else {
            Write-RunLog 'S03' 'WHATS_WRONG' 24 'PASS' 'Rebuild PASS; What''s Wrong/Feature errors=0; warnings=0.'
        }

        $saveErr = 0; $saveWarn = 0
        $stagedOk = [Q347F.SwValidationApi]::SaveAs($model, $SkeletonStagingPath, [ref]$saveErr, [ref]$saveWarn)
        if (-not $stagedOk -or $saveErr -ne 0) {
            throw "Failed to save staging skeleton. SaveOk=$stagedOk ErrorCode=$saveErr WarningCode=$saveWarn"
        }
        Write-RunLog 'S03' 'SAVE' 24 'PASS' ("Staging skeleton saved: {0}" -f $SkeletonStagingPath)

        $previousBackup = $null
        if (Test-Path -LiteralPath $SkeletonFinalPath) {
            $previousBackup = Join-Path $RunBackupDir '00_SKELETON_previous_PASS.SLDPRT'
            Copy-Item -LiteralPath $SkeletonFinalPath -Destination $previousBackup -Force
            Write-RunLog 'S03' 'BACKUP' 24 'PASS' ("Previous skeleton backed up: {0}" -f $previousBackup)

            $closedOld = [Q347F.SwSessionApi]::CloseDocumentByPath($script:SwSession, $SkeletonFinalPath)
            if ($closedOld) {
                Write-RunLog 'S03' 'PUBLISH' 24 'PASS' 'Previously published 00_SKELETON.SLDPRT was open in SOLIDWORKS and was closed automatically before overwrite.'
                Start-Sleep -Milliseconds 300
            }
        }

        $saveErr2 = 0; $saveWarn2 = 0
        $publishedOk = [Q347F.SwValidationApi]::SaveAs($model, $SkeletonFinalPath, [ref]$saveErr2, [ref]$saveWarn2)
        if (-not $publishedOk -or $saveErr2 -ne 0) {
            if ($previousBackup -and (Test-Path -LiteralPath $previousBackup)) {
                try { Copy-Item -LiteralPath $previousBackup -Destination $SkeletonFinalPath -Force } catch { }
            }
            throw "Failed to publish final skeleton. SaveOk=$publishedOk ErrorCode=$saveErr2 WarningCode=$saveWarn2. If Windows still reports the file is in use, close any external viewer/process holding 00_SKELETON.SLDPRT."
        }

        $planeCount = [Q347F.SwValidationApi]::CountFeatureType($model, 'RefPlane')
        $axisCount = [Q347F.SwValidationApi]::CountFeatureType($model, 'RefAxis')
        Write-RunLog 'S03' 'SAVE' 25 'PASS' ("00_SKELETON.SLDPRT published. RefPlaneCount={0}, RefAxisCount={1}, SaveWarnings={2}" -f $planeCount, $axisCount, $saveWarn2)
        Set-StepStatus 'S03' 'PASS' 'S03 PASS'
    }
    catch {
        if ($null -ne $model) {
            try {
                $se = 0; $sw = 0
                [void][Q347F.SwValidationApi]::SaveAs($model, $SkeletonStagingPath, [ref]$se, [ref]$sw)
            } catch { }
        }
        throw
    }
    finally {
        if (-not $KeepSolidWorksOpen -and $null -ne $model) {
            [Q347F.SwSessionApi]::CloseDocument($script:SwSession, $model)
        }
    }
}
