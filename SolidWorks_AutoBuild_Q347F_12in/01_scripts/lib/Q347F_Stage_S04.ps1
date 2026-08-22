function Invoke-S04 {
    Set-StepStatus 'S04' 'RUNNING' 'S04 started'
    Write-RunLog 'S04' 'BALL' 25 'RUNNING' 'Creating editable 01_BALL.SLDPRT from TEMP-FROZEN manufacturing dimensions.'

    $model = $null
    try {
        $model = [Q347F.SwSessionApi]::NewPart($script:SwSession, $script:PartTemplate)
        Write-RunLog 'S04' 'BALL' 26 'PASS' 'New Ball Part created from configured SOLIDWORKS 2025 template.'

        $eqCount = [Q347F.SwEquationApi]::ImportOrUpdateEquations($model, $ParameterFile)
        Write-RunLog 'S04' 'EQUATIONS' 26 'PASS' ("Global variables imported/updated. EquationCount={0}" -f $eqCount)

        $basePlanes = [Q347F.SwGeometryApi]::CreateProjectBasePlanes($model)
        $axes = [Q347F.SwGeometryApi]::CreateProjectAxes($model)
        Write-RunLog 'S04' 'BASES' 27 'PASS' ("Project bases/axes created: {0}; {1}" -f ($basePlanes -join ', '), ($axes -join ', '))

        $ballR = Get-Param 'BALL_R'
        $upperDepth = Get-Param 'BALL_UPPER_BORE_DEPTH'
        $lowerDepth = Get-Param 'BALL_LOWER_BORE_DEPTH'
        $slotStartZ = $ballR - $upperDepth

        $topPlane = Convert-StationName 'Z' $ballR
        $bottomPlane = Convert-StationName 'Z' (-$ballR)
        $slotPlane = Convert-StationName 'Z' $slotStartZ
        [void][Q347F.SwGeometryApi]::CreateStationPlane($model, 'Z', $ballR, $topPlane)
        [void][Q347F.SwGeometryApi]::CreateStationPlane($model, 'Z', (-$ballR), $bottomPlane)
        [void][Q347F.SwGeometryApi]::CreateStationPlane($model, 'Z', $slotStartZ, $slotPlane)
        Write-RunLog 'S04' 'DATUMS' 27 'PASS' ("Ball manufacturing datum planes: top Z=+{0}, bottom Z=-{0}, drive-slot start Z={1} mm." -f $ballR, $slotStartZ)

        $coreName = [Q347F.SwBallApi]::CreateBallCore(
            $model,
            'PLN_BASE_XZ_FLOW_SUPPORT',
            'AXIS_X_FLOW',
            (Get-Param 'BALL_OD'),
            (Get-Param 'BALL_W_X'))
        Write-RunLog 'S04' 'BALL_CORE' 29 'PASS' ("{0}: spherical OD φ{1}, finished X width={2} mm." -f $coreName, (Get-Param 'BALL_OD'), (Get-Param 'BALL_W_X'))

        $boreName = [Q347F.SwBallApi]::CreateThroughBore($model, 'PLN_BASE_YZ_CROSS_SUPPORT', (Get-Param 'BORE_D'))
        Write-RunLog 'S04' 'FLOW_BORE' 30 'PASS' ("{0}: full through flow bore φ{1} along X." -f $boreName, (Get-Param 'BORE_D'))

        $upperName = [Q347F.SwBallApi]::CreateBlindRoundCut(
            $model,
            $topPlane,
            'SK_UPPER_SUPPORT_BORE_D105',
            'CUT_UPPER_SUPPORT_BORE_D105',
            (Get-Param 'BALL_UPPER_BORE_D'),
            $upperDepth,
            $false)
        Write-RunLog 'S04' 'UPPER_SUPPORT' 31 'PASS' ("{0}: φ{1} x {2} total depth, TEMP-FROZEN manufacturing value." -f $upperName, (Get-Param 'BALL_UPPER_BORE_D'), $upperDepth)

        $slotName = [Q347F.SwBallApi]::CreateRoundedRectangleBlindCut(
            $model,
            $slotPlane,
            (Get-Param 'BALL_DRIVE_SLOT_L_X'),
            (Get-Param 'BALL_DRIVE_SLOT_W_Y'),
            (Get-Param 'BALL_DRIVE_SLOT_R'),
            (Get-Param 'BALL_DRIVE_SLOT_DEPTH'),
            $false)
        Write-RunLog 'S04' 'DRIVE_SLOT' 32 'PASS' ("{0}: {1}x{2} R{3} x depth {4} from upper-bore bottom plane." -f $slotName, (Get-Param 'BALL_DRIVE_SLOT_L_X'), (Get-Param 'BALL_DRIVE_SLOT_W_Y'), (Get-Param 'BALL_DRIVE_SLOT_R'), (Get-Param 'BALL_DRIVE_SLOT_DEPTH'))

        $lowerName = [Q347F.SwBallApi]::CreateBlindRoundCut(
            $model,
            $bottomPlane,
            'SK_LOWER_SUPPORT_BORE_D70',
            'CUT_LOWER_SUPPORT_BORE_D70',
            (Get-Param 'BALL_LOWER_BORE_D'),
            $lowerDepth,
            $true)
        Write-RunLog 'S04' 'LOWER_SUPPORT' 32 'PASS' ("{0}: φ{1} x {2} total depth, TEMP-FROZEN manufacturing value." -f $lowerName, (Get-Param 'BALL_LOWER_BORE_D'), $lowerDepth)

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
            'CUT_UPPER_DRIVE_SLOT_70x50_R8',
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
        Assert-Near 'BALL audit Z OD' $zSpan (Get-Param 'BALL_OD') 3.0
        Write-RunLog 'S04' 'AUDIT' 33 'PASS' ("SolidBodyCount=1; approximate body box X={0:N3}, Y={1:N3}, Z={2:N3} mm." -f $xSpan, $ySpan, $zSpan)

        if ($validation.WarningCount -gt 0) {
            Write-RunLog 'S04' 'WHATS_WRONG' 33 'WARN' ("BALL rebuild PASS; errors=0; warnings={0}." -f $validation.WarningCount)
        } else {
            Write-RunLog 'S04' 'WHATS_WRONG' 33 'PASS' 'BALL rebuild PASS; What''s Wrong errors=0; warnings=0.'
        }

        $saveErr = 0; $saveWarn = 0
        $stagedOk = [Q347F.SwValidationApi]::SaveAs($model, $BallStagingPath, [ref]$saveErr, [ref]$saveWarn)
        if (-not $stagedOk -or $saveErr -ne 0) {
            throw "Failed to save staging BALL. SaveOk=$stagedOk ErrorCode=$saveErr WarningCode=$saveWarn"
        }
        Write-RunLog 'S04' 'SAVE' 33 'PASS' ("Staging BALL saved: {0}" -f $BallStagingPath)

        $previousBackup = $null
        if (Test-Path -LiteralPath $BallFinalPath) {
            $previousBackup = Join-Path $RunBackupDir '01_BALL_previous_PASS.SLDPRT'
            Copy-Item -LiteralPath $BallFinalPath -Destination $previousBackup -Force
            Write-RunLog 'S04' 'BACKUP' 33 'PASS' ("Previous BALL backed up: {0}" -f $previousBackup)
        }

        $saveErr2 = 0; $saveWarn2 = 0
        $publishedOk = [Q347F.SwValidationApi]::SaveAs($model, $BallFinalPath, [ref]$saveErr2, [ref]$saveWarn2)
        if (-not $publishedOk -or $saveErr2 -ne 0) {
            if ($previousBackup -and (Test-Path -LiteralPath $previousBackup)) {
                Copy-Item -LiteralPath $previousBackup -Destination $BallFinalPath -Force
            }
            throw "Failed to publish final BALL. SaveOk=$publishedOk ErrorCode=$saveErr2 WarningCode=$saveWarn2"
        }

        Write-RunLog 'S04' 'SAVE' 34 'PASS' ("01_BALL.SLDPRT published: {0}; SaveWarnings={1}" -f $BallFinalPath, $saveWarn2)
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
