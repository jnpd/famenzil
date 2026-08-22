[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$SourcePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AutoRoot = Split-Path -Parent $ScriptDir
$Inner = Join-Path $ScriptDir 'Inspect_Reference_Assembly.ps1'

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

    # Main Q347F assembly begins with 20Q347F-300LB but does not have a numeric
    # subassembly suffix such as -05. If an original and a copied assembly coexist,
    # shortest filename is treated as the canonical root.
    $familyRoots = @(
        $assemblies |
        Where-Object { $_.BaseName -match '^20Q347F-300LB(?!-\d)' } |
        Sort-Object @{Expression={ $_.Name.Length }}, @{Expression={ $_.FullName.Length }}
    )

    if ($familyRoots.Count -gt 0) {
        $rootAssembly = $familyRoots[0].FullName
    }
    else {
        $rootAssembly = ($assemblies | Sort-Object @{Expression={ ($_.FullName -split '[\\/]').Count }}, @{Expression={ $_.Name.Length }} | Select-Object -First 1).FullName
    }
}

Write-Host ("[A00][PASS] Root assembly selected: {0}" -f $rootAssembly) -ForegroundColor Green

# The uploaded Pack and Go contains a second top-level copy. It is not part of the
# manufacturing structure we want to reverse-engineer and can fail to open because its
# references are stale. Because ZIP content was extracted into a disposable log folder,
# safely hide only those extra top-level copies from the inner recursive scanner.
if ($isExtractedZip) {
    $rootDir = Split-Path -Parent $rootAssembly
    $extraRoots = @(
        Get-ChildItem -LiteralPath $rootDir -File -Filter '*.SLDASM' |
        Where-Object {
            $_.FullName -ine $rootAssembly -and
            $_.BaseName -match '^20Q347F-300LB(?!-\d)'
        }
    )
    foreach ($extra in $extraRoots) {
        $skipName = $extra.Name + '.skip'
        Rename-Item -LiteralPath $extra.FullName -NewName $skipName -Force
        Write-Host ("[A00][SKIP] Extra top-level assembly copy excluded: {0}" -f $extra.Name) -ForegroundColor DarkYellow
    }
}

& $Inner -SourcePath $rootAssembly -OutputDir $OutputDir
exit $LASTEXITCODE
