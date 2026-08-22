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
    echo [FAIL] Q347F S00-S03 自动建模未通过。请保留 04_logs\run_xxx 目录用于排查。
    echo 断点续跑：一键生成12寸Q347F.bat resume
    pause
    exit /b %RC%
)

echo [PASS] S00-S03 已通过，00_SKELETON.SLDPRT 已生成。
echo 当前版本故意停在 S03，不会继续生成 BALL / BODY 等零件。
pause
exit /b 0
