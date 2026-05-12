Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$raw = [Console]::In.ReadToEnd()
if (-not $raw.Trim()) { exit 0 }
try { $data = $raw | ConvertFrom-Json } catch { exit 0 }

$cwd = if ($data.PSObject.Properties['cwd']) { $data.cwd } else { '' }
if (-not $cwd) { exit 0 }

$contextParts = @()

# 1. Manifest Check
$manifestPath = Join-Path $cwd ".atlas\manifest.json"
if (-not (Test-Path $manifestPath)) {
    $contextParts += "SYSTEM DIRECTIVE: Workspace uninitialized. .atlas/manifest.json is MISSING. You MUST delegate to killua and oracle to scan the repo and generate this manifest BEFORE proceeding with the user's request."
}

# 2. Repo Memories
$memoriesDir = Join-Path $cwd "memories\repo"
if (Test-Path $memoriesDir) {
    $memSummary = ""
    Get-ChildItem -Path $memoriesDir -Filter *.json | ForEach-Object {
        $memoryPath = $_.FullName
        try {
            $json = Get-Content $memoryPath -Raw | ConvertFrom-Json
            if ($json.subject -and $json.fact) { $memSummary += "- $($json.subject): $($json.fact)`n" }
        } catch {
            $message = "session-start: failed to read repo memory '$memoryPath': $($_.Exception.Message)"
            [Console]::Error.WriteLine($message)
            Write-Verbose $message
        }
    }
    if ($memSummary) { $contextParts += "Project conventions:`n$memSummary" }
}

if ($contextParts.Count -eq 0) { exit 0 }
$compiled = $contextParts -join "`n"

[PSCustomObject]@{ hookSpecificOutput = @{ hookEventName = 'SessionStart'; additionalContext = $compiled } } | ConvertTo-Json -Compress
exit 0