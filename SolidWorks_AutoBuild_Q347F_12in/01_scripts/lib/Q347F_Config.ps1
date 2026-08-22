function Get-Q347FBuildConfig {
    $configPath = Join-Path $AutoRoot '00_config\build_config.json'
    if (-not (Test-Path -LiteralPath $configPath)) {
        return $null
    }

    try {
        $cfg = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
        return $cfg
    }
    catch {
        throw ("BLOCKED: build_config.json cannot be parsed: {0}" -f $_.Exception.Message)
    }
}

function Resolve-Q347FConfiguredPath {
    param([string]$FileName)

    $cfg = Get-Q347FBuildConfig
    if ($null -eq $cfg -or $null -eq $cfg.solidWorks) { return $null }

    $sw = $cfg.solidWorks

    if ($FileName -ieq 'SLDWORKS.exe') {
        if (-not [string]::IsNullOrWhiteSpace([string]$sw.exePath)) {
            $explicitExe = [Environment]::ExpandEnvironmentVariables([string]$sw.exePath)
            if (Test-Path -LiteralPath $explicitExe) {
                return (Resolve-Path -LiteralPath $explicitExe).Path
            }
            throw ("BLOCKED: configured solidWorks.exePath does not exist: {0}" -f $explicitExe)
        }

        if (-not [string]::IsNullOrWhiteSpace([string]$sw.installDir)) {
            $installDir = [Environment]::ExpandEnvironmentVariables([string]$sw.installDir).TrimEnd('\')
            $candidate = Join-Path $installDir 'SLDWORKS.exe'
            if (Test-Path -LiteralPath $candidate) {
                return (Resolve-Path -LiteralPath $candidate).Path
            }

            if (-not [bool]$sw.autoDiscoverFallback) {
                throw ("BLOCKED: configured SolidWorks installDir exists in config, but SLDWORKS.exe was not found at: {0}" -f $candidate)
            }
        }
        return $null
    }

    if ($FileName -ieq 'SolidWorks.Interop.sldworks.dll') {
        if (-not [string]::IsNullOrWhiteSpace([string]$sw.interopSldworksDll)) {
            $p = [Environment]::ExpandEnvironmentVariables([string]$sw.interopSldworksDll)
            if (Test-Path -LiteralPath $p) { return (Resolve-Path -LiteralPath $p).Path }
            throw ("BLOCKED: configured interopSldworksDll does not exist: {0}" -f $p)
        }
    }

    if ($FileName -ieq 'SolidWorks.Interop.swconst.dll') {
        if (-not [string]::IsNullOrWhiteSpace([string]$sw.interopSwconstDll)) {
            $p = [Environment]::ExpandEnvironmentVariables([string]$sw.interopSwconstDll)
            if (Test-Path -LiteralPath $p) { return (Resolve-Path -LiteralPath $p).Path }
            throw ("BLOCKED: configured interopSwconstDll does not exist: {0}" -f $p)
        }
    }

    if (-not [string]::IsNullOrWhiteSpace([string]$sw.installDir)) {
        $installDir = [Environment]::ExpandEnvironmentVariables([string]$sw.installDir).TrimEnd('\')
        $dllCandidates = @(
            (Join-Path $installDir ("api\redist\{0}" -f $FileName)),
            (Join-Path $installDir $FileName)
        )
        foreach ($candidate in $dllCandidates) {
            if (Test-Path -LiteralPath $candidate) {
                return (Resolve-Path -LiteralPath $candidate).Path
            }
        }
    }

    return $null
}

function Get-Q347FConfiguredPartTemplate {
    $cfg = Get-Q347FBuildConfig
    if ($null -eq $cfg -or $null -eq $cfg.templates) { return $null }
    $p = [string]$cfg.templates.partTemplatePath
    if ([string]::IsNullOrWhiteSpace($p)) { return $null }
    $p = [Environment]::ExpandEnvironmentVariables($p)
    if (-not (Test-Path -LiteralPath $p)) {
        throw ("BLOCKED: configured partTemplatePath does not exist: {0}" -f $p)
    }
    return (Resolve-Path -LiteralPath $p).Path
}

# Override the generic finder so S00 first honors machine-specific config.
function Find-SolidWorksFile([string]$FileName) {
    $configured = Resolve-Q347FConfiguredPath -FileName $FileName
    if ($configured) { return $configured }

    $cfg = Get-Q347FBuildConfig
    if ($cfg -and $cfg.solidWorks -and ($cfg.solidWorks.autoDiscoverFallback -eq $false)) {
        return $null
    }

    $roots = @()
    if ($env:ProgramFiles) { $roots += (Join-Path $env:ProgramFiles 'SOLIDWORKS Corp') }
    if (${env:ProgramFiles(x86)}) { $roots += (Join-Path ${env:ProgramFiles(x86)} 'SOLIDWORKS Corp') }

    foreach ($root in $roots | Select-Object -Unique) {
        if (Test-Path -LiteralPath $root) {
            $found = Get-ChildItem -LiteralPath $root -Filter $FileName -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($found) { return $found.FullName }
        }
    }
    return $null
}
