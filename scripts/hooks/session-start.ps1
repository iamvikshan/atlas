# SessionStart hook: Compiles project context from repo memories, git state,
# and project metadata for atlas session awareness.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$raw = [Console]::In.ReadToEnd()
if (-not $raw.Trim()) { exit 0 }
try { $data = $raw | ConvertFrom-Json } catch { exit 0 }

$cwd = if ($data.PSObject.Properties['cwd']) { [string]$data.cwd } else { '' }
if (-not $cwd) { exit 0 }

$parts = [System.Collections.Generic.List[string]]::new()

$memoriesDir = Join-Path $cwd 'memories\repo'
if (Test-Path $memoriesDir -PathType Container) {
    $summary = ''
    foreach ($f in Get-ChildItem $memoriesDir -Filter '*.json' -ErrorAction SilentlyContinue) {
        try {
            $mem = Get-Content $f.FullName -Raw | ConvertFrom-Json
            if ($mem.PSObject.Properties['subject'] -and $mem.PSObject.Properties['fact']) {
                $summary += "- $($mem.subject): $($mem.fact)`n"
            }
        } catch {}
    }
    if ($summary) { $parts.Add("Project conventions:`n$summary") }
}

if (Get-Command git -ErrorAction SilentlyContinue) {
    if (Test-Path (Join-Path $cwd '.git') -PathType Container) {
        $branch = git -C $cwd branch --show-current 2>$null
        if ($branch) { $parts.Add("Git branch: $branch") }
    }
}

$pkgJson = Join-Path $cwd 'package.json'
$pyproj  = Join-Path $cwd 'pyproject.toml'
if (Test-Path $pkgJson) {
    try {
        $pkg = Get-Content $pkgJson -Raw | ConvertFrom-Json
        if ($pkg.PSObject.Properties['name'] -and $pkg.name) {
            $parts.Add("Project: $($pkg.name) (Node.js)")
        }
    } catch {}
} elseif (Test-Path $pyproj) {
    try {
        $pyLines = Get-Content $pyproj -ErrorAction Stop
        $inProjectSection = $false
        foreach ($pyLine in $pyLines) {
            if ($pyLine -match '^\[project\]') { $inProjectSection = $true; continue }
            if ($inProjectSection -and $pyLine -match '^\[') { break }
            if ($inProjectSection) {
                if ($pyLine -match "^\s*name\s*=\s*'([^']+)'\s*$") {
                    $parts.Add("Project: $($Matches[1]) (Python)"); break
                }
                if ($pyLine -match '^\s*name\s*=\s*"([^"]+)"\s*$') {
                    $parts.Add("Project: $($Matches[1]) (Python)"); break
                }
            }
        }
    } catch {}
}

if (Get-Command node -ErrorAction SilentlyContinue) {
    $v = node --version 2>$null; if ($v) { $parts.Add("Node: $v") }
}
if (Get-Command python3 -ErrorAction SilentlyContinue) {
    $v = python3 --version 2>$null
    if ($v) { $parts.Add("Python: $($v -replace 'Python ','')") }
}

if ($parts.Count -eq 0) { exit 0 }

$compiled = $parts -join "`n"
[PSCustomObject]@{
    hookSpecificOutput = [PSCustomObject]@{
        hookEventName   = 'SessionStart'
        additionalContext = $compiled
    }
} | ConvertTo-Json -Compress -Depth 5
exit 0
