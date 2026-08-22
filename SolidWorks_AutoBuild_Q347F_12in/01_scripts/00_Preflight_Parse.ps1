[CmdletBinding()]
param(
    [string]$Root
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($Root)) {
    $Root = Split-Path -Parent $MyInvocation.MyCommand.Path
}

$files = Get-ChildItem -LiteralPath $Root -Filter '*.ps1' -File -Recurse | Sort-Object FullName
if (-not $files) {
    Write-Host '[PREFLIGHT][FAIL] No PowerShell files found.' -ForegroundColor Red
    exit 90
}

$failed = $false
foreach ($file in $files) {
    $tokens = $null
    $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors) | Out-Null

    if ($errors.Count -gt 0) {
        $failed = $true
        Write-Host ('[PREFLIGHT][FAIL] {0}' -f $file.FullName) -ForegroundColor Red
        foreach ($err in $errors) {
            $line = $err.Extent.StartLineNumber
            $column = $err.Extent.StartColumnNumber
            Write-Host ('  line={0} col={1} id={2} message={3}' -f $line, $column, $err.ErrorId, $err.Message) -ForegroundColor Red
        }
    } else {
        Write-Host ('[PREFLIGHT][PASS] {0}' -f $file.Name) -ForegroundColor DarkGray
    }
}

if ($failed) {
    Write-Host '[PREFLIGHT][BLOCKED] PowerShell syntax errors must be fixed before S00.' -ForegroundColor Red
    exit 90
}

Write-Host ('[PREFLIGHT][PASS] Parsed {0} PowerShell files with zero syntax errors.' -f $files.Count) -ForegroundColor Green
exit 0
