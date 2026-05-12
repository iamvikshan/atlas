Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$raw = [Console]::In.ReadToEnd()
if (-not $raw.Trim()) { exit 0 }
try { $data = $raw | ConvertFrom-Json } catch { exit 0 }

$stopHookActive = if ($data.PSObject.Properties['stop_hook_active']) { [string]$data.stop_hook_active } else { 'false' }
if ($stopHookActive -eq 'true') { exit 0 }

$cwd = if ($data.PSObject.Properties['cwd']) { $data.cwd } else { '' }
if (-not $cwd -or -not (Test-Path $cwd)) { exit 0 }

$warnings = @()

# 1. Git check
if (Get-Command git -ErrorAction SilentlyContinue) {
    $gitDir = Join-Path $cwd ".git"
    if (Test-Path $gitDir) {
        $dirty = & git -C $cwd status --porcelain 2>$null
        if ($dirty) {
            $count = ($dirty | Measure-Object).Count
            $warnings += "Uncommitted changes detected ($count files). Consider committing or stashing."
        }
    }
}

# 2. Temp files check (Hunting scratchpads)
$tempFiles = Get-ChildItem -Path $cwd -Recurse -Depth 4 -Directory:$false -ErrorAction SilentlyContinue |
    Where-Object { 
        $_.FullName -notmatch '[\\/]node_modules[\\/]' -and 
        $_.FullName -notmatch '[\\/]\.git[\\/]' -and
        ($_.Name -match '\.(tmp|bak)$' -or $_.Name -match '^(debug|scratch)-') 
    }

if ($tempFiles) {
    $count = @($tempFiles).Count
    $warnings += "Found $count temp/debug artifact(s) in workspace. Clean up orphaned scratchpads: *.tmp, *.bak, debug-*, scratch-*"
}

if ($warnings.Count -eq 0) { exit 0 }

$compiled = ($warnings | ForEach-Object { "- $_" }) -join "`n"

[PSCustomObject]@{ systemMessage = $compiled } | ConvertTo-Json -Compress
exit 0