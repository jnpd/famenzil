[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$SourcePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AutoRoot = Split-Path -Parent $ScriptDir
$Inner = Join-Path $ScriptDir 'Inspect_Reference_Assembly_V3.ps1'

$SourcePath = [Environment]::ExpandEnvironmentVariables($SourcePath)
if (-not (Test-Path -LiteralPath $SourcePath)) { throw "Source not found: $SourcePath" }
$SourcePath = (Resolve-Path -LiteralPath $SourcePath).Path

$OutputDir = Join-Path $AutoRoot ('04_logs\reference_assembly_{0}' -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$ext = [IO.Path]::GetExtension($SourcePath)
$scanRoot = $null
$rootAssembly = $null
$isExtractedZip = $false

if ($ext -ieq '.zip') {
    $extract = Join-Path $OutputDir 'pack_and_go_extracted'
    New-Item -ItemType Directory -Force -Path $extract | Out-Null
    Write-Host ("[A00][RUNNING] Extracting Pack and Go ZIP: {0}" -f $SourcePath) -ForegroundColor Cyan
    Expand-Archive -LiteralPath $SourcePath -DestinationPath $extract -Force
    Write-Host ("[A00][PASS] ZIP extracted to: {0}" -f $extract) -ForegroundColor Green
    $scanRoot = $extract
    $isExtractedZip = $true
}
elseif (Test-Path -LiteralPath $SourcePath -PathType Container) {
    $scanRoot = $SourcePath
}
elseif ($ext -ieq '.sldasm') {
    $rootAssembly = $SourcePath
    $scanRoot = Split-Path -Parent $SourcePath
}
else {
    throw 'SourcePath must be a Pack and Go .zip, folder, or .SLDASM.'
}

if (-not $rootAssembly) {
    $assemblies = @(Get-ChildItem -LiteralPath $scanRoot -Recurse -File -Filter '*.SLDASM')
    if ($assemblies.Count -eq 0) { throw "No .SLDASM files found under: $scanRoot" }
    $familyRoots = @(
        $assemblies |
        Where-Object { $_.BaseName -match '^20Q347F-300LB(?!-\d)' } |
        Sort-Object @{Expression={ $_.Name.Length }}, @{Expression={ $_.FullName.Length }}
    )
    if ($familyRoots.Count -gt 0) { $rootAssembly = $familyRoots[0].FullName }
    else { $rootAssembly = ($assemblies | Sort-Object @{Expression={ ($_.FullName -split '[\\/]').Count }}, @{Expression={ $_.Name.Length }} | Select-Object -First 1).FullName }
}

Write-Host ("[A00][PASS] Root assembly selected: {0}" -f $rootAssembly) -ForegroundColor Green

if ($isExtractedZip) {
    $rootDir = Split-Path -Parent $rootAssembly
    $extraRoots = @(Get-ChildItem -LiteralPath $rootDir -File -Filter '*.SLDASM' | Where-Object { $_.FullName -ine $rootAssembly -and $_.BaseName -match '^20Q347F-300LB(?!-\d)' })
    foreach ($extra in $extraRoots) {
        Rename-Item -LiteralPath $extra.FullName -NewName ($extra.Name + '.skip') -Force
        Write-Host ("[A00][SKIP] Extra top-level assembly copy excluded: {0}" -f $extra.Name) -ForegroundColor DarkYellow
    }
}

$exitCode = 1
try {
    & $Inner -RootAssemblyPath $rootAssembly -OutputDir $OutputDir

    $summaryPath = Join-Path $OutputDir '20in_summary.json'
    if (-not (Test-Path -LiteralPath $summaryPath)) {
        throw 'Inspector returned without 20in_summary.json; result cannot be accepted.'
    }

    $summary = Get-Content -LiteralPath $summaryPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $partExpected = [int]$summary.SldprtFiles
    $partDone = [int]$summary.PartReportsCompleted
    $components = [int]$summary.MainAssemblyComponentInstances
    $missing = [int]$summary.MissingReferences
    $errors = [int]$summary.Errors

    Write-Host ("[A98][VERIFY] Components={0}; Parts={1}/{2}; MissingRefs={3}; Errors={4}" -f $components,$partDone,$partExpected,$missing,$errors) -ForegroundColor Cyan

    if ($components -le 0) { throw 'Acceptance failed: top assembly component count is 0.' }
    if ($partExpected -le 0) { throw 'Acceptance failed: no SLDPRT files were discovered.' }
    if ($partDone -ne $partExpected) { throw ("Acceptance failed: only {0}/{1} part reports completed." -f $partDone,$partExpected) }
    if ($missing -ne 0) { throw ("Acceptance failed: {0} missing component references remain." -f $missing) }
    if ($errors -ne 0) { throw ("Acceptance failed: {0} inspection errors remain." -f $errors) }

    Write-Host '[A99][PASS] Full reference assembly inspection verified.' -ForegroundColor Green
    $exitCode = 0
}
catch {
    Write-Host ("[A99][FAIL] {0}" -f $_.Exception.Message) -ForegroundColor Red
    $exitCode = 1
}
finally {
    $isolatedPidText = [Environment]::GetEnvironmentVariable('Q347F_ISOLATED_SW_PID')
    if (-not [string]::IsNullOrWhiteSpace($isolatedPidText)) {
        $isolatedPid = 0
        if ([int]::TryParse($isolatedPidText, [ref]$isolatedPid) -and $isolatedPid -gt 0) {
            $p = Get-Process -Id $isolatedPid -ErrorAction SilentlyContinue
            if ($null -ne $p) {
                Write-Host ("[A98][CLEANUP] Closing isolated SOLIDWORKS PID={0}" -f $isolatedPid) -ForegroundColor DarkGray
                Stop-Process -Id $isolatedPid -Force -ErrorAction SilentlyContinue
            }
        }
        [Environment]::SetEnvironmentVariable('Q347F_ISOLATED_SW_PID', $null)
    }
}

exit $exitCode
