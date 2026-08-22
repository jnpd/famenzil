@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

if "%~1"=="" (
    echo.
    echo Please drag the 20in BALL .SLDPRT file onto this BAT file.
    echo Example: 20Q347F-300LB-03 BALL.SLDPRT
    echo.
    pause
    exit /b 2
)

set "PART_PATH=%~1"
echo.
echo [RUNNING] Inspecting reference BALL:
echo %PART_PATH%
echo.

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0\01_scripts\Inspect_Reference_Ball.ps1" -PartPath "%PART_PATH%"
set "RC=%ERRORLEVEL%"

echo.
if not "%RC%"=="0" (
    echo [FAIL] Reference BALL inspection failed.
    pause
    exit /b %RC%
)

echo [PASS] Reference BALL feature tree and dimensions were exported under 04_logs\reference_ball_xxx\
pause
exit /b 0
