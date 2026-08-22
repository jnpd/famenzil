@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

set "RESUME_ARG="
if /I "%~1"=="resume" set "RESUME_ARG=-Resume"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0\01_scripts\Build_Q347F_12in.ps1" %RESUME_ARG%
set "RC=%ERRORLEVEL%"

echo.
if not "%RC%"=="0" (
    echo [FAIL] Q347F S00-S03 build failed.
    echo Keep the latest 04_logs\run_xxx folder for troubleshooting.
    echo Resume command: this BAT file with argument resume
    pause
    exit /b %RC%
)

echo [PASS] S00-S03 completed. 00_SKELETON.SLDPRT was generated.
echo This version intentionally stops after S03.
pause
exit /b 0
