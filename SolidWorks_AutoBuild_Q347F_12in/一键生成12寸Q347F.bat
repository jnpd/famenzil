@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

set "RESUME_ARG="
if /I "%~1"=="resume" set "RESUME_ARG=-Resume"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0\01_scripts\00_Preflight_Parse.ps1" -Root "%~dp0\01_scripts"
set "PREFLIGHT_RC=%ERRORLEVEL%"
if not "%PREFLIGHT_RC%"=="0" (
    echo.
    echo [FAIL] PowerShell syntax preflight failed. Build did not enter S00.
    pause
    exit /b %PREFLIGHT_RC%
)

echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0\01_scripts\Build_Q347F_12in.ps1" %RESUME_ARG%
set "RC=%ERRORLEVEL%"

echo.
if not "%RC%"=="0" (
    echo [FAIL] Q347F S00-S04 build failed.
    echo Keep the latest 04_logs\run_xxx folder for troubleshooting.
    echo Resume command: this BAT file with argument resume
    pause
    exit /b %RC%
)

echo [PASS] S00-S04 completed.
echo Generated: 02_output\00_SKELETON.SLDPRT
echo Generated: 02_output\01_BALL.SLDPRT
echo BALL uses current TEMP-FROZEN manufacturing dimensions for first complete CAD build.
pause
exit /b 0
