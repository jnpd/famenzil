. (Join-Path $ScriptDir 'lib\Q347F_SwBallProcessHoleApi.ps1')

function Invoke-S04 {
    Set-StepStatus 'S04' 'RUNNING' 'S04 started'
    Add-EmbeddedSwBallProcessHoleApiType
    Write-RunLog 'S04' 'BALL' 25 'RUNNING' 'Creating editable 12in 01_BALL.SLDPRT. The 20in source is read-only topology reference; 20in dimensions are not copied into the 12in model.'

    $model = $null
    try {
        $model = [Q347F.SwSessionApi]::NewPart($script:SwSession, $script:PartTemplate)
        Write-RunLog 'S04' 'BALL' 26 'PASS' 'New 12in Ball Part created from configured SOLIDWORKS 2025 template.'

        $eqCount = [Q347F.SwEquationApi]::ImportOrUpdateEquations($model, $ParameterFile)
        Write-RunLog 'S04' 'EQUATIONS' 26 'PASS' ("12in global variables imported/updated. EquationCount={0}" -f $eqCount)

        $basePlanes = [Q347F.SwGeometryApi]::CreateProjectBasePlanes($model)
        $axes = [Q347F.SwGeometryApi]::CreateProjectAxes($model)
        Write-RunLog 'S04' 'BASES' 27 'PASS' ("Project bases/axes created: {0}; {1}" -f ($basePlanes -join ', '), ($axes -join ', '))

        $ballR = Get-Param 'BALL_R'
        $upperBoreR = (Get-Param 'BALL_UPPER_BORE_D') / 2.0
        $lowerBoreR = (Get-Param 'BALL_LOWER_BORE_D') / 2.0

        # IMPORTANT S04 V2 semantics:
        # UP_BRG_L / LOWER_BRG_L are the 12in bearing straight working lengths.
        # They are NOT the blind-cut depth measured from the sphere apex.
        $upperBearingL = Get-Param 'UP_BRG_L'
        $upperBoreBottomZ = Get-Param 'UP_BRG_Z0'
        $upperBoreTopZ = Get-Param 'UP_BRG_Z1'
        $lowerBearingL = Get-Param 'LOWER_BRG_L'
        $lowerBoreInnerZ = Get-Param 'LOWER_BRG_Z_IN'
        $lowerBoreOuterZ = Get-Param 'LOWER_BRG_Z_OUT'

        Assert-Near '12in upper bearing envelope length' ($upperBoreTopZ - $upperBoreBottomZ) $upperBearingL 0.2
        Assert-Near '12in lower bearing envelope length' ($lowerBoreInnerZ - $lowerBoreOuterZ) $lowerBearingL 0.2

        $upperCutDepth = $ballR - $upperBoreBottomZ
        $lowerCutDepth = $ballR + $lowerBoreInnerZ
        Assert-True ($upperCutDepth -gt $upperBearingL) 'Upper support cut must include the spherical mouth transition plus the full bearing working length.'
        Assert-True ($lowerCutDepth -gt $lowerBearingL) 'Lower support cut must include the spherical mouth transition plus the full bearing working length.'

        # Deep inspection of the 20in reference proved the mature drive-slot orientation is X-short / Y-long.
        # The 12in parameter ledger is now normalized directly as X44 x Y70 R8 x depth27.
        $slotX = Get-Param 'BALL_DRIVE_SLOT_L_X'
        $slotY = Get-Param 'BALL_DRIVE_SLOT_W_Y'
        $slotR = Get-Param 'BALL_DRIVE_SLOT_R'
        $slotDepth = Get-Param 'BALL_DRIVE_SLOT_DEPTH'
        Assert-Near '12in drive slot X candidate' $slotX 44.0 0.2
        Assert-Near '12in drive slot Y candidate' $slotY 70.0 0.2
        Assert-Near '12in drive slot R candidate' $slotR 8.0 0.2
        Assert-Near '12in drive slot depth candidate' $slotDepth 27.0 0.2

        $slotStartZ = $upperBoreBottomZ
        $slotEndZ = $slotStartZ - $slotDepth

        # 12in process-hole CAD candidates. REF20 only supplies the topology: two symmetric stepped threaded holes.
        # These values are explicitly 12in CAD candidates and are not manufacturing-frozen.
        $procQty = [int](Get-Param 'BALL_PROC_HOLE_QTY')
        $procOffsetX = Get-Param 'BALL_PROC_HOLE_CENTER_OFFSET_X_CAD'
        $procDatumZ = Get-Param 'BALL_PROC_DATUM_Z_CAD'
        $procCounterD = Get-Param 'BALL_PROC_COUNTERBORE_D_CAD'
        $procCounterCut = Get-Param 'BALL_PROC_COUNTERBORE_CUT_FROM_DATUM_CAD'
        $procThreadD = Get-Param 'BALL_PROC_THREAD_D_CAD'
        $procTapDrillD = Get-Param 'BALL_PROC_TAP_DRILL_D_CAD'
        $procPilotCut = Get-Param 'BALL_PROC_PILOT_CUT_FROM_DATUM_CAD'
        $procThreadDepth = Get-Param 'BALL_PROC_THREAD_DEPTH_CAD'

        Assert-True ($procQty -eq 2) '12in BALL process-hole topology requires exactly 2 symmetric holes.'
        Assert-True ($procOffsetX -gt ($upperBoreR + ($procCounterD / 2.0))) '12in process counterbores must not intersect the D105 upper support bore.'
        Assert-True ($procCounterD -gt $procTapDrillD) '12in process-hole counterbore diameter must exceed tap-drill diameter.'
        Assert-True ($procPilotCut -gt $procCounterCut) '12in process-hole pilot cut must be deeper than the counterbore cut.'

        $procLigament = $procOffsetX - $upperBoreR - ($procCounterD / 2.0)
        Assert-True ($procLigament -ge 5.0) ("12in process-hole radial ligament to D105 bore is too small: {0:N3} mm." -f $procLigament)

        $procSphereSurfaceZ = [Math]::Sqrt([Math]::Max(0.0, ($ballR * $ballR) - ($procOffsetX * $procOffsetX)))
        $procAirGap = [Math]::Max(0.0, $procDatumZ - $procSphereSurfaceZ)
        $procCounterMaterialDepth = $procCounterCut - $procAirGap
        $procPilotMaterialDepth = $procPilotCut - $procAirGap
        Assert-True ($procCounterMaterialDepth -gt 3.0) ("12in process counterbore does not reach enough material. Effective material depth={0:N3} mm." -f $procCounterMaterialDepth)
        Assert-True ($procPilotMaterialDepth -gt $procThreadDepth) ("12in process pilot hole is too shallow for the M{0} CAD-candidate thread depth. Effective pilot material depth={1:N3} mm; thread depth candidate={2:N3} mm." -f $procThreadD,$procPilotMaterialDepth,$procThreadDepth)

        # Final body Z envelope after the polar support cuts. The off-axis process holes do not govern the global extrema.
        $upperSphereEdgeZ = [Math]::Sqrt([Math]::Max(0.0, ($ballR * $ballR) - ($upperBoreR * $upperBoreR)))
        $lowerSphereEdgeAbsZ = [Math]::Sqrt([Math]::Max(0.0, ($ballR * $ballR) - ($lowerBoreR * $lowerBoreR)))
        $expectedZMax = $upperSphereEdgeZ
        $expectedZMin = -$lowerSphereEdgeAbsZ
        $expectedZSpan = $expectedZMax - $expectedZMin

        Write-RunLog 'S04' 'REF20_TOPOLOGY' 27 'PASS' 'REF20 decoded as topology only: X70 x Y112 R12 drive slot and two symmetric D35/M20 stepped process holes. S04 uses separate 12in CAD candidates; no 20in dimension is copied directly.'
        Write-RunLog 'S04' 'PLAN_AUDIT' 27 'PASS' ("12in support plan: upper D{0} bearing zone Z={1:N3}..{2:N3} (L={3}); tangent cut={4:N3}; lower D{5} bearing zone Z={6:N3}..{7:N3} (L={8}); tangent cut={9:N3}." -f (Get-Param 'BALL_UPPER_BORE_D'),$upperBoreBottomZ,$upperBoreTopZ,$upperBearingL,$upperCutDepth,(Get-Param 'BALL_LOWER_BORE_D'),$lowerBoreOuterZ,$lowerBoreInnerZ,$lowerBearingL,$lowerCutDepth)
        Write-RunLog 'S04' 'PROCESS_HOLES' 27 'PASS' ("12in CAD-candidate plan: 2X at X=+/-{0}; counterbore D{1}, datum Z={2}, total cut={3} (effective material ~{4:N3}); M{5} candidate tap drill D{6}, total cut={7} (effective material ~{8:N3}); radial ligament to D105={9:N3} mm." -f $procOffsetX,$procCounterD,$procDatumZ,$procCounterCut,$procCounterMaterialDepth,$procThreadD,$procTapDrillD,$procPilotCut,$procPilotMaterialDepth,$procLigament)
        Write-RunLog 'S04' 'PLAN_AUDIT' 27 'PASS' ("Expected final body envelope: Zmin={0:N3}, Zmax={1:N3}, Zspan={2:N3} mm." -f $expectedZMin, $expectedZMax, $expectedZSpan)

        $topPlane = Convert-StationName 'Z' $ballR
        $bottomPlane = Convert-StationName 'Z' (-$ballR)
        $slotPlane = Convert-StationName 'Z' $slotStartZ
        $processPlane = Convert-StationName 'Z' $procDatumZ
        [void][Q347F.SwGeometryApi]::CreateStationPlane($model, 'Z', $ballR, $topPlane)
        [void][Q347F.SwGeometryApi]::CreateStationPlane($model, 'Z', (-$ballR), $bottomPlane)
        [void][Q347F.SwGeometryApi]::CreateStationPlane($model, 'Z', $slotStartZ, $slotPlane)
        [void][Q347F.SwGeometryApi]::CreateStationPlane($model, 'Z', $procDatumZ, $processPlane)
        Write-RunLog 'S04' 'DATUMS' 27 'PASS' ("12in BALL datums: sphere top Z=+{0}, sphere bottom Z=-{0}, upper bore bottom / drive-slot start Z={1}, slot end Z={2}, process-hole datum Z={3} mm." -f $ballR,$slotStartZ,$slotEndZ,$procDatumZ)

        $coreName = [Q347F.SwBallApi]::CreateBallCore(
            $model,
            'PLN_BASE_XZ_FLOW_SUPPORT',
            'AXIS_X_FLOW',
            (Get-Param 'BALL_OD'),
            (Get-Param 'BALL_W_X'))
        Write-RunLog 'S04' 'BALL_CORE' 29 'PASS' ("{0}: 12in spherical OD D{1}, finished X width={2} mm." -f $coreName, (Get-Param 'BALL_OD'), (Get-Param 'BALL_W_X'))

        $boreName = [Q347F.SwBallApi]::CreateThroughBore($model, 'PLN_BASE_YZ_CROSS_SUPPORT', (Get-Param 'BORE_D'))
        Write-RunLog 'S04' 'FLOW_BORE' 30 'PASS' ("{0}: 12in full through flow bore D{1} along X." -f $boreName, (Get-Param 'BORE_D'))

        $upperName = [Q347F.SwBallApi]::CreateBlindRoundCut(
            $model,
            $topPlane,
            'SK_UPPER_SUPPORT_BORE_D105',
            'CUT_UPPER_SUPPORT_BORE_D105',
            (Get-Param 'BALL_UPPER_BORE_D'),
            $upperCutDepth,
            $false)
        Write-RunLog 'S04' 'UPPER_SUPPORT' 31 'PASS' ("{0}: 12in D{1}; reaches Z={2:N3}; bearing working zone Z={2:N3}..{3:N3}, L={4} mm. Total tangent-plane cut={5:N3} mm." -f $upperName,(Get-Param 'BALL_UPPER_BORE_D'),$upperBoreBottomZ,$upperBoreTopZ,$upperBearingL,$upperCutDepth)

        Write-RunLog 'S04' 'DRIVE_SLOT' 31 'RUNNING' ("Creating 12in upper drive slot X{0} x Y{1} R{2}, depth={3} mm from Z={4:N3}." -f $slotX,$slotY,$slotR,$slotDepth,$slotStartZ)
        $slotName = [Q347F.SwBallApi]::CreateRoundedRectangleBlindCut(
            $model,
            $slotPlane,
            $slotX,
            $slotY,
            $slotR,
            $slotDepth,
            $false)
        Write-RunLog 'S04' 'DRIVE_SLOT' 32 'PASS' ("{0}: 12in geometry X{1} x Y{2} R{3} x depth {4}; Z {5:N3}->{6:N3}." -f $slotName,$slotX,$slotY,$slotR,$slotDepth,$slotStartZ,$slotEndZ)

        Write-RunLog 'S04' 'PROCESS_HOLES' 32 'RUNNING' ("Creating 12in 2X stepped process holes at X=+/-{0}: D{1} counterbore + D{2} tap-drill for M{3} CAD candidate." -f $procOffsetX,$procCounterD,$procTapDrillD,$procThreadD)
        $processNames = [Q347F.SwBallProcessHoleApi]::CreateTwoStageProcessHoles(
            $model,
            $processPlane,
            $procOffsetX,
            $procCounterD,
            $procCounterCut,
            $procTapDrillD,
            $procPilotCut,
            $false)
        Write-RunLog 'S04' 'PROCESS_HOLES' 32 'PASS' ("12in process-hole topology created: {0}. M{1} is CAD candidate only; real Hole Wizard/cosmetic thread waits for manufacturing freeze." -f ($processNames -join ', '),$procThreadD)

        $lowerName = [Q347F.SwBallApi]::CreateBlindRoundCut(
            $model,
            $bottomPlane,
            'SK_LOWER_SUPPORT_BORE_D70',
            'CUT_LOWER_SUPPORT_BORE_D70',
            (Get-Param 'BALL_LOWER_BORE_D'),
            $lowerCutDepth,
            $true)
        Write-RunLog 'S04' 'LOWER_SUPPORT' 32 'PASS' ("{0}: 12in D{1}; reaches Z={2:N3}; bearing working zone Z={3:N3}..{2:N3}, L={4} mm. Total tangent-plane cut={5:N3} mm." -f $lowerName,(Get-Param 'BALL_LOWER_BORE_D'),$lowerBoreInnerZ,$lowerBoreOuterZ,$lowerBearingL,$lowerCutDepth)

        $validation = [Q347F.SwValidationApi]::Validate($model)
        if (-not $validation.RebuildOk) {
            throw 'BALL rebuild failed: IModelDoc2.ForceRebuild3 returned false.'
        }
        foreach ($item in $validation.Items) {
            $s = if ($item.IsWarning) { 'WARN' } else { 'FAIL' }
            $msg = "Feature=$($item.FeatureName) Type=$($item.FeatureType) ErrorCode=$($item.ErrorCode)"
            Write-RunLog 'S04' 'WHATS_WRONG' 33 $s $msg
            if ($item.IsWarning) { Add-RunWarning $msg } else { Add-RunError $msg }
        }
        if ($validation.ErrorCount -gt 0) {
            throw "BALL What's Wrong / feature validation found $($validation.ErrorCount) error(s)."
        }

        $required = @(
            'BALL_CORE',
            'SK_BALL_PROFILE',
            'CUT_BORE_D303',
            'CUT_UPPER_SUPPORT_BORE_D105',
            'CUT_UPPER_DRIVE_SLOT_70x44_R8',
            'CUT_PROCESS_COUNTERBORE_2X',
            'CUT_PROCESS_TAP_DRILL_2X',
            'CUT_LOWER_SUPPORT_BORE_D70'
        )
        foreach ($f in $required) {
            Assert-True ([Q347F.SwValidationApi]::FeatureExists($model, $f)) ("BALL required feature missing: {0}" -f $f)
        }

        $audit = [Q347F.SwBallApi]::Audit($model)
        Assert-True ($audit.SolidBodyCount -eq 1) ("BALL must contain exactly one solid body; actual={0}" -f $audit.SolidBodyCount)
        $xSpan = $audit.XMaxMm - $audit.XMinMm
        $ySpan = $audit.YMaxMm - $audit.YMinMm
        $zSpan = $audit.ZMaxMm - $audit.ZMinMm
        Assert-Near 'BALL audit X width' $xSpan (Get-Param 'BALL_W_X') 3.0
        Assert-Near 'BALL audit Y OD' $ySpan (Get-Param 'BALL_OD') 3.0
        Assert-Near 'BALL audit Z max after D105 support cut' $audit.ZMaxMm $expectedZMax 3.0
        Assert-Near 'BALL audit Z min after D70 support cut' $audit.ZMinMm $expectedZMin 3.0
        Assert-Near 'BALL audit Z span after support cuts' $zSpan $expectedZSpan 3.0
        Write-RunLog 'S04' 'AUDIT' 33 'PASS' ("12in Ball: SolidBodyCount=1; body box X={0:N3}, Y={1:N3}, Z={2:N3} mm; expected post-support-cut Z={3:N3} mm; process-hole radial ligament={4:N3} mm." -f $xSpan,$ySpan,$zSpan,$expectedZSpan,$procLigament)

        if ($validation.WarningCount -gt 0) {
            Write-RunLog 'S04' 'WHATS_WRONG' 33 'WARN' ("BALL rebuild PASS; errors=0; warnings={0}." -f $validation.WarningCount)
        } else {
            Write-RunLog 'S04' 'WHATS_WRONG' 33 'PASS' 'BALL rebuild PASS; What''s Wrong errors=0; warnings=0.'
        }

        [Q347F.SwBallApi]::ApplyPresentationAppearance($model)
        Write-RunLog 'S04' 'PRESENTATION' 33 'PASS' 'Readable neutral industrial-grey appearance applied; reference planes, axes and sketches hidden for saved view.'

        $saveErr = 0; $saveWarn = 0
        $stagedOk = [Q347F.SwValidationApi]::SaveAs($model, $BallStagingPath, [ref]$saveErr, [ref]$saveWarn)
        if (-not $stagedOk -or $saveErr -ne 0) {
            throw "Failed to save staging BALL. SaveOk=$stagedOk ErrorCode=$saveErr WarningCode=$saveWarn"
        }
        Write-RunLog 'S04' 'SAVE' 33 'PASS' ("Staging 12in BALL saved: {0}" -f $BallStagingPath)

        $previousBackup = $null
        if (Test-Path -LiteralPath $BallFinalPath) {
            $previousBackup = Join-Path $RunBackupDir '01_BALL_previous_PASS.SLDPRT'
            Copy-Item -LiteralPath $BallFinalPath -Destination $previousBackup -Force
            Write-RunLog 'S04' 'BACKUP' 33 'PASS' ("Previous BALL backed up: {0}" -f $previousBackup)

            $closedOld = [Q347F.SwSessionApi]::CloseDocumentByPath($script:SwSession, $BallFinalPath)
            if ($closedOld) {
                Write-RunLog 'S04' 'PUBLISH' 33 'PASS' 'Previously published 01_BALL.SLDPRT was open in SOLIDWORKS and was closed automatically before overwrite.'
                Start-Sleep -Milliseconds 300
            }
        }

        $saveErr2 = 0; $saveWarn2 = 0
        $publishedOk = [Q347F.SwValidationApi]::SaveAs($model, $BallFinalPath, [ref]$saveErr2, [ref]$saveWarn2)
        if (-not $publishedOk -or $saveErr2 -ne 0) {
            if ($previousBackup -and (Test-Path -LiteralPath $previousBackup)) {
                try { Copy-Item -LiteralPath $previousBackup -Destination $BallFinalPath -Force } catch { }
            }
            throw "Failed to publish final BALL. SaveOk=$publishedOk ErrorCode=$saveErr2 WarningCode=$saveWarn2. If Windows still reports the file is in use, close any external viewer/process holding 01_BALL.SLDPRT."
        }

        Write-RunLog 'S04' 'SAVE' 34 'PASS' ("12in 01_BALL.SLDPRT published: {0}; SaveWarnings={1}" -f $BallFinalPath,$saveWarn2)
        Set-StepStatus 'S04' 'PASS' 'S04 PASS'
    }
    catch {
        if ($null -ne $model) {
            try {
                $se = 0; $sw = 0
                [void][Q347F.SwValidationApi]::SaveAs($model, $BallStagingPath, [ref]$se, [ref]$sw)
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
