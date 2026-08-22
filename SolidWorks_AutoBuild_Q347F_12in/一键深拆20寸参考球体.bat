@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

echo ============================================================
echo Q347F BALL REFERENCE DEEP INSPECTION
echo TARGET    : 12in NPS12 DN300 Class150
echo REFERENCE : 20in 300LB BALL - READ ONLY
echo ============================================================

echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0\01_scripts\00_Preflight_Parse.ps1" -Root "%~dp0\01_scripts"
set "PREFLIGHT_RC=%ERRORLEVEL%"
if not "%PREFLIGHT_RC%"=="0" (
    echo.
    echo [FAIL] PowerShell syntax preflight failed.
    pause
    exit /b %PREFLIGHT_RC%
)

echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0\01_scripts\Inspect_Reference_Ball_Deep.ps1"
set "RC=%ERRORLEVEL%"

echo.
if not "%RC%"=="0" (
    echo [FAIL] 20in reference BALL deep inspection failed.
    echo Send the full console output to ChatGPT.
    pause
    exit /b %RC%
)

echo [PASS] Reference deep inspection completed.
echo Upload the newest 04_logs\reference_ball_deep_xxx folder or ZIP it.
pause
exit /b 0
