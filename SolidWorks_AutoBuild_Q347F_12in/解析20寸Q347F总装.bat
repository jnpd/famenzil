@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

if "%~1"=="" (
    echo.
    echo Drag one of the following onto this BAT file:
    echo   1. 20Q347F-300LB_PackAndGo.zip
    echo   2. Pack and Go folder
    echo   3. 20Q347F-300LB total assembly .SLDASM
    echo.
    echo This inspector is READ-ONLY. It does not modify the 20in source files.
    echo.
    pause
    exit /b 2
)

set "SOURCE_PATH=%~1"
set "Q347F_FORCE_ISOLATED_SW=1"
echo.
echo ============================================================
echo Q347F 20in FULL ASSEMBLY REVERSE INSPECTION
echo Source: %SOURCE_PATH%
echo ============================================================
echo.
echo [INFO] Reference inspection will start an ISOLATED SOLIDWORKS instance.
echo [INFO] Your existing SOLIDWORKS session will not be reused or closed.
echo [INFO] Do not close the isolated SOLIDWORKS window until the script reports COMPLETE.
echo.

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0\01_scripts\Inspect_Reference_Assembly_Entry.ps1" -SourcePath "%SOURCE_PATH%"
set "RC=%ERRORLEVEL%"

echo.
if not "%RC%"=="0" (
    echo [FAIL] 20in assembly inspection stopped.
    echo Check the newest 04_logs\reference_assembly_xxx folder.
    pause
    exit /b %RC%
)

echo [PASS] 20in assembly/component/mate/transform/part-feature ledgers exported.
echo Output: 04_logs\reference_assembly_xxx\
echo.
pause
exit /b 0
